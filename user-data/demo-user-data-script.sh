#!/bin/bash -x
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
#
# !!!IMPORTANT!!!
# Edit this file and change this next line to your own email address:
#

EMAIL=youraddress@example.com

# Upgrade and install Postfix so we can send a sample email
export DEBIAN_FRONTEND=noninteractive
apt-get update && apt-get upgrade -y && apt-get install -y postfix

# Get some information about the running instance
instance_id=$(wget -qO- instance-data/latest/meta-data/instance-id)
public_ip=$(wget -qO- instance-data/latest/meta-data/public-ipv4)
zone=$(wget -qO- instance-data/latest/meta-data/placement/availability-zone)
region=$(expr match $zone '\(.*\).')
uptime=$(uptime)

# Send status email
/usr/sbin/sendmail -oi -t -f $EMAIL <<EOM
From: $EMAIL
To: $EMAIL
Subject: Results of EC2 scheduled AutoScaling demo

This email message was generated on the following EC2 instance:

  instance id: $instance_id
  region:      $region
  public ip:   $public_ip
  uptime:      $uptime

If the instance is still running, you can monitor the output of this
job using a command like:

  ssh ubuntu@$public_ip tail -1000f /var/log/user-data.log

  ec2-describe-instances --region $region $instance_id

For more information about this demo:

  Running EC2 Instances on a Recurring Schedule with Auto Scaling
  http://alestic.com/2011/11/ec2-schedule-instance

EOM

# Give the email some time to be queued and delivered
sleep 300 # 5 minutes

# This will stop the EBS boot instance, stopping the hourly charges.
# Have Auto Scaling terminate it, stopping the storage charges.
shutdown -h now

exit 0

########################################################################
#
# For more information about this code, please read:
#
#   Running EC2 Instances on a Recurring Schedule with Auto Scaling
#   http://alestic.com/2011/11/ec2-schedule-instance
#
# The code and its license are available on github:
#
#   https://github.com/alestic/demo-ec2-schedule-instance
#
########################################################################
