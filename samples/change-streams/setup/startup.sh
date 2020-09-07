#!/bin/bash

# Update instance and install packages
echo -e "[mongodb-org-3.6] \nname=MongoDB Repository\nbaseurl=https://repo.mongodb.org/yum/amazon/2013.03/mongodb-org/3.6/x86_64/\ngpgcheck=1 \nenabled=1 \ngpgkey=https://www.mongodb.org/static/pgp/server-3.6.asc" | sudo tee /etc/yum.repos.d/mongodb-org-3.6.repo
sudo yum update -y
sudo yum install -y jq moreutils
sudo yum install -y mongodb-org-shell
sudo python -m pip install pymongo
wget https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem

# Upgrade pip
sudo pip3 install --upgrade pip
echo "export PATH=~/.local/bin:$PATH" >> ~/.bash_profile
source ~/.bash_profile

# Upgrade awscli
pip3 install awscli --upgrade --user
source ~/.bash_profile

# Upload Lambda Code
cd..
mkdir app && cd app
wget https://raw.githubusercontent.com/aws-samples/amazon-documentdb-samples/master/samples/change-streams/app/lambda_function.py
wget https://raw.githubusercontent.com/aws-samples/amazon-documentdb-samples/master/samples/change-streams/app/requirements.txt
python -m venv repLambda
source repLambda/bin/activate
mv lambda_function.py repLambda/lib/python*/site-packages/
mv requirements.txt repLambda/lib/python*/site-packages/
cd repLambda/lib/python*/site-packages/
pip install -r requirements.txt 
deactivate
mv ../dist-packages/* .
zip -r9 repLambdaFunction.zip .
aws s3 cp repLambdaFunction.zip s3://$S3_BUCKET