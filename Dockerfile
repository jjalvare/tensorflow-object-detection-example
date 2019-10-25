FROM ibmcom/tensorflow-ppc64le
  

ENV DEBIAN_FRONTEND=noninteractive
ENV IS_DOCKER_APP 1
ENV DOCKER_APP_PATH /root/app/
ENV DOCKER_VENV /root/anaconda3/envs/app/
# ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

# Updating Ubuntu packages
RUN apt-get update && yes | apt-get upgrade
# RUN apt-get install -y emacs

RUN apt-get install -y software-properties-common 

RUN apt-get update && \
    apt-get install -y \
    git \
    wget \
    vim \
    curl \ 
    bzip2 build-essential libssl-dev libffi-dev python3-dev python3 python3-pip protobuf-compiler python3-pil python-lxml python-tk python-pip
RUN pip install Flask==0.12.2 WTForms==2.1 Flask_WTF==0.14.2 Werkzeug==0.12.2 
RUN cd /opt/ && git clone https://github.com/tensorflow/models && cd models/research && protoc object_detection/protos/*.proto --python_out=.
RUN cd /opt/ && git clone https://github.com/jjalvare/tensorflow-object-detection-example
WORKDIR /opt/tensorflow-object-detection-example/object_detection_app
#
RUN wget -O /root/Anaconda2-2019.10-Linux-ppc64le.sh https://repo.anaconda.com/archive/Anaconda2-2019.10-Linux-ppc64le.sh
RUN bash  /root/Anaconda2-2019.10-Linux-ppc64le.sh -b
RUN /root/anaconda2/bin/conda  config --prepend channels https://public.dhe.ibm.com/ibmdl/export/pub/software/server/ibm-ai/conda/ &&/root/anaconda2/bin/conda config --add channels conda-forge &&/root/anaconda2/bin/conda config --set channel_priority strict
COPY ./conda_env /opt/
#WORKDIR /root/app 
RUN  /root/anaconda2/bin/conda create --name wlce_env --file /opt/conda_env  
# && /root/anaconda2/bin/activate wlce_env && /root/anaconda2/bin/conda install matplotlib=3.1.1 
ENV PYTHONPATH="${PYTHONPATH}:/root/anaconda2/envs/wlce_env/lib/python3.6/site-packages/"
RUN sed -i -r "s/self.detection_graph = self._build_graph\(\)//g" app.py
RUN sed -i -r "s/self.sess = tf.compat.v1.Session\(graph=self.detection_graph\)//g" app.py
RUN sed -i -r "s/tf.gfile.GFile/tf.io.gfile.GFile/g" /opt/models/research/object_detection/utils/label_map_util.py
RUN sed -i -r "s/localhost/object-detect/g" app.py
RUN pip install Flask==0.12.2 WTForms==2.1 Flask_WTF==0.14.2 Werkzeug==0.12.2 requests
ENTRYPOINT [ "python3", "app.py"] 
