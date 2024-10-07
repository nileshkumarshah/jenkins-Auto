FROM python:3.8

# Update and install prerequisites in one RUN statement
RUN apt-get update && apt-get install -y \
    poppler-utils \
    software-properties-common \
    python3-opencv \
    nginx \
    supervisor \
    systemd \
    libaio1 && \
    pip install opencv-python && \
    # Install Oracle DB client Files
    mkdir -p /opt/oracle && \
    cd /opt/oracle && \
    wget https://download.oracle.com/otn_software/linux/instantclient/215000/instantclient-basic-linux.x64-21.5.0.0.0dbru.zip && \
    unzip instantclient-basic-linux.x64-21.5.0.0.0dbru.zip && \
    sh -c "echo /opt/oracle/instantclient_21_5 > /etc/ld.so.conf.d/oracle-instantclient.conf" && \
    ldconfig && \
    rm -rf /var/lib/apt/lists/* /opt/oracle/instantclient-basic-linux.x64-21.5.0.0.0dbru.zip

# Set environment variables
ENV PATH="/opt/oracle/instantclient_21_5:${PATH}"
ENV LD_LIBRARY_PATH="/opt/oracle/instantclient_21_5:${LD_LIBRARY_PATH}"
ENV LD_RUN_PATH="${LD_LIBRARY_PATH}"
ENV TZ="Asia/Kolkata"

# Setup python environment
RUN mkdir /code
WORKDIR /code
COPY new_requirements.txt .
RUN pip install -r new_requirements.txt

# Copy project files
COPY . .

# Make the script executable
RUN chmod a+x run.sh

# Default command
CMD ["./run.sh"]