resource "aws_launch_template" "app_lt" {
  name_prefix   = "app-launch-template-"
  image_id      = var.ec2_ami
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.ec2-sg.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash

              # Update system and install required packages
              yum update -y
              yum install -y python3 python3-pip awscli jq

              # Install Python packages
              pip3 install Flask pymysql cryptography

              # Create application directory
              mkdir -p /opt/app
              cd /opt/app

              # Get RDS credentials from AWS Secrets Manager
              SECRET=$(aws secretsmanager get-secret-value \
                --secret-id "${aws_db_instance.db.master_user_secret[0].secret_arn}" \
                --query SecretString \
                --output text \
                --region "${var.region}")

              # Extract credentials from the secret
              DB_USER=$(echo "$SECRET" | jq -r '.username')
              DB_PASSWORD=$(echo "$SECRET" | jq -r '.password')

              # RDS endpoint and database name
              DB_HOST="${aws_db_instance.db.address}"
              DB_NAME="${var.db_name}"

              # Create environment file for the Flask application
              cat << ENVEOF > /opt/app/.env
              DB_HOST=$DB_HOST
              DB_USER=$DB_USER
              DB_PASSWORD=$DB_PASSWORD
              DB_NAME=$DB_NAME
              ENVEOF

              # Write Flask application
              cat << 'PYEOF' > /opt/app/app.py
              import os
              from flask import Flask, request, jsonify
              import pymysql

              app = Flask(__name__)

              DB_HOST = os.environ.get("DB_HOST")
              DB_USER = os.environ.get("DB_USER")
              DB_PASSWORD = os.environ.get("DB_PASSWORD")
              DB_NAME = os.environ.get("DB_NAME")

              def get_db_connection():
                  return pymysql.connect(
                      host=DB_HOST,
                      user=DB_USER,
                      password=DB_PASSWORD,
                      database=DB_NAME,
                      cursorclass=pymysql.cursors.DictCursor
                  )

              def init_db():
                  try:
                      conn = get_db_connection()
                      with conn.cursor() as cursor:
                          cursor.execute("""
                              CREATE TABLE IF NOT EXISTS items (
                                  id INT AUTO_INCREMENT PRIMARY KEY,
                                  name VARCHAR(255) NOT NULL
                              )
                          """)
                      conn.commit()
                      conn.close()
                  except Exception as e:
                      print(f"Error initializing DB: {e}")

              @app.route('/health', methods=['GET'])
              def health():
                  return jsonify({"status": "healthy"}), 200

              @app.route('/items', methods=['GET'])
              def get_items():
                  try:
                      conn = get_db_connection()
                      with conn.cursor() as cursor:
                          cursor.execute("SELECT * FROM items;")
                          items = cursor.fetchall()
                      conn.close()
                      return jsonify(items), 200
                  except Exception as e:
                      return jsonify({"error": str(e)}), 500

              @app.route('/items', methods=['POST'])
              def add_item():
                  data = request.get_json()

                  if not data or 'name' not in data:
                      return jsonify({"error": "Name is required"}), 400

                  try:
                      conn = get_db_connection()

                      with conn.cursor() as cursor:
                          cursor.execute(
                              "INSERT INTO items (name) VALUES (%s)",
                              (data['name'],)
                          )

                      conn.commit()
                      conn.close()

                      return jsonify({
                          "message": "Item added successfully"
                      }), 201

                  except Exception as e:
                      return jsonify({"error": str(e)}), 500

              if __name__ == '__main__':
                  init_db()
                  app.run(host='0.0.0.0', port=8080)
              PYEOF

              # Create systemd service
              cat << 'SERVICE_EOF' > /etc/systemd/system/flaskapp.service
              [Unit]
              Description=Flask Application
              After=network.target

              [Service]
              User=root
              WorkingDirectory=/opt/app

              # Load database environment variables
              EnvironmentFile=/opt/app/.env

              ExecStart=/usr/bin/python3 /opt/app/app.py
              Restart=always

              [Install]
              WantedBy=multi-user.target
              SERVICE_EOF

              # Start Flask application
              systemctl daemon-reload
              systemctl enable flaskapp
              systemctl start flaskapp

              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "asg-flask-instance"
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      encrypted             = true
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

}

resource "aws_autoscaling_group" "app_asg" {
  name_prefix               = "app-asg-"
  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  desired_capacity          = var.asg_desired_capacity
  vpc_zone_identifier       = [aws_subnet.private-1.id, aws_subnet.private-2.id]
  target_group_arns         = [aws_lb_target_group.target.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                   = "cpu-target-tracking-70"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.asg_cpu_target
  }
}