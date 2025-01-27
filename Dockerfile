FROM summerwind/actions-runner:latest  
  
USER root  
  
ENV TERRAFORM_VERSION="1.9.8"  
ENV KUBELOGIN_VERSION="v0.0.24"  
ENV KUBECTL_VERSION="v1.28.0"  
ENV GH_RUNNER_VERSION="2.283.3"  
ENV HELM_VERSION="v3.12.0"  
ENV PWSH_VERSION="7.4.6"  
ENV DEBIAN_FRONTEND=noninteractive  
ENV TZ=Etc/UTC

RUN apt-get update && apt-get -y install \  
   curl \  
   apt-utils \  
   unzip \  
   ca-certificates \  
   tzdata \  
   lsb-release \  
   gnupg \  
   bash \  
   p7zip-full \  
   git \  
   iputils-ping \  
   tar \  
   wget \  
   software-properties-common \  
   jq \  
   python3 && \  
   ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \  
   dpkg-reconfigure -f noninteractive tzdata && \  
   apt-get clean && apt-get autoremove
  
WORKDIR /actions-runner
  
# Install Powershell Core  
RUN wget -LO "https://github.com/PowerShell/PowerShell/releases/download/v${PWSH_VERSION}/powershell_${PWSH_VERSION}-1.deb_amd64.deb" && \  
   dpkg -i "powershell_${PWSH_VERSION}-1.deb_amd64.deb" || apt-get install -f -y && \  
   rm -f "powershell_${PWSH_VERSION}-1.deb_amd64.deb" && \  
   apt-get clean && apt-get autoremove
  
# Install Azure CLI  
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor --batch --yes -o /etc/apt/trusted.gpg.d/microsoft.gpg && \
    AZ_REPO=$(lsb_release -cs) && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" > /etc/apt/sources.list.d/azure-cli.list && \
    apt-get update -y && \
    apt-get install -y azure-cli && \
    rm -rf /var/lib/apt/lists/*
  
# Configure Python  
RUN ln -sf /usr/bin/python3 /usr/bin/python  
  
# Install Terraform  
RUN curl -LO "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    unzip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip
  
# Install Node.js 18.x  
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \  
   && apt-get install -y nodejs  
  
# Install kubelogin  
RUN curl -LO "https://github.com/Azure/kubelogin/releases/download/${KUBELOGIN_VERSION}/kubelogin-linux-amd64.zip" \  
   && unzip kubelogin-linux-amd64.zip -d /usr/local/bin \  
   && mv /usr/local/bin/bin/linux_amd64/kubelogin /usr/local/bin/kubelogin \  
   && rm -rf /usr/local/bin/bin kubelogin-linux-amd64.zip  
  
# Install kubectl  
RUN curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \  
   && chmod +x kubectl \  
   && mv kubectl /usr/local/bin/  
  
# Install Docker CLI  
RUN apt-get install -y docker.io  
  
# Install Helm  
RUN curl -LO "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" \  
   && tar -zxvf "helm-${HELM_VERSION}-linux-amd64.tar.gz" \  
   && mv linux-amd64/helm /usr/local/bin/ \  
   && rm -rf linux-amd64 "helm-${HELM_VERSION}-linux-amd64.tar.gz"  
  
# Install Java 8, Java 17, and Java 21
# Install OpenJDK 8, 17, and 21 from the default repositories
RUN apt-get update && apt-get install -y \
    openjdk-8-jdk \
    openjdk-17-jdk \
    openjdk-21-jdk \
    && apt-get clean && apt-get autoremove

# Download and install OpenJDK 18 and 20 manually
RUN wget https://download.oracle.com/java/18/archive/jdk-18.0.2.1_linux-x64_bin.deb \
    https://download.oracle.com/java/20/archive/jdk-20.0.2_linux-x64_bin.deb \
    && apt install -y ./jdk-18.0.2.1_linux-x64_bin.deb ./jdk-20.0.2_linux-x64_bin.deb \
    && rm jdk-18.0.2.1_linux-x64_bin.deb jdk-20.0.2_linux-x64_bin.deb

# Set Java alternatives
RUN update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-8-openjdk-amd64/bin/java 1 \
    && update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-17-openjdk-amd64/bin/java 2 \
    && update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk-18/bin/java 3 \
    && update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk-20/bin/java 4 \
    && update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-21-openjdk-amd64/bin/java 5 \
    && update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/java-8-openjdk-amd64/bin/javac 1 \
    && update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/java-17-openjdk-amd64/bin/javac 2 \
    && update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/jdk-18/bin/javac 3 \
    && update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/jdk-20/bin/javac 4 \
    && update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/java-21-openjdk-amd64/bin/javac 5

# Create aliases to Java versions
RUN ln -s /usr/lib/jvm/java-8-openjdk-amd64/bin/java /usr/local/bin/java8 && \
    ln -s /usr/lib/jvm/java-8-openjdk-amd64/bin/javac /usr/local/bin/javac8 && \
    ln -s /usr/lib/jvm/java-17-openjdk-amd64/bin/java /usr/local/bin/java17 && \
    ln -s /usr/lib/jvm/java-17-openjdk-amd64/bin/javac /usr/local/bin/javac17 && \
    ln -s /usr/lib/jvm/jdk-18/bin/java /usr/local/bin/java18 && \
    ln -s /usr/lib/jvm/jdk-18/bin/javac /usr/local/bin/javac18 && \
    ln -s /usr/lib/jvm/jdk-20/bin/java /usr/local/bin/java20 && \
    ln -s /usr/lib/jvm/jdk-20/bin/javac /usr/local/bin/javac20 && \
    ln -s /usr/lib/jvm/java-21-openjdk-amd64/bin/java /usr/local/bin/java21 && \
    ln -s /usr/lib/jvm/java-21-openjdk-amd64/bin/javac /usr/local/bin/javac21

# Set default Java version to 8
RUN update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/bin/java \
    && update-alternatives --set javac /usr/lib/jvm/java-8-openjdk-amd64/bin/javac

# Set default Java version to 17
# RUN update-alternatives --set java /usr/lib/jvm/java-17-openjdk-amd64/bin/java \
#     && update-alternatives --set javac /usr/lib/jvm/java-17-openjdk-amd64/bin/javac

# Set default Java version to 21
# RUN update-alternatives --set java /usr/lib/jvm/java-21-openjdk-amd64/bin/java \
#     && update-alternatives --set javac /usr/lib/jvm/java-21-openjdk-amd64/bin/javac
  
USER runner