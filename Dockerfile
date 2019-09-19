FROM postgres:alpine

# Install Dependencies
RUN apk add --no-cache py-pip curl openrc nodejs npm

# Install AWS CLI
RUN pip install awscli --upgrade

# Install Kubernetes CLI
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin/kubectl

# Install eksctl
RUN curl --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
RUN mv /tmp/eksctl /usr/local/bin

# Insall AWS-IAM-Authenticator
RUN curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.12.7/2019-03-27/bin/linux/amd64/aws-iam-authenticator
RUN chmod +x ./aws-iam-authenticator
RUN mv ./aws-iam-authenticator /usr/local/bin

# Set up Postgres
USER postgres
RUN initdb /var/lib/postgresql/data
USER root
RUN echo "host all  all    0.0.0.0/0  md5" >> /var/lib/postgresql/data/pg_hba.conf
USER postgres
RUN pg_ctl start -D /var/lib/postgresql/data -l /var/lib/postgresql/log.log && psql --command "ALTER USER postgres PASSWORD 'postgres';"
VOLUME /var/lib/postgresql/data