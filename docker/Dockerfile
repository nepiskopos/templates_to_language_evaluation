FROM nvidia/cuda:10.0-base-ubuntu18.04


MAINTAINER Nikos Episkopos nepiskopos[at]fogus[dot]gr



# Update apt sources
RUN DEBIAN_FRONTEND="noninteractive" apt-get update

# Set locale to en-US
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install locales
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8



# Switch to /root as working directory
WORKDIR /root/

# Create a bashrc file
RUN cp /etc/skel/.bashrc ./



# Install necessary tools

# Install system tools through apt
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install wget git tar nano unzip build-essential

# Download, install and initialize conda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -P /root/
RUN bash /root/Miniconda3-latest-Linux-x86_64.sh -b -p /root/miniconda3
RUN /root/miniconda3/condabin/conda init bash
RUN /root/miniconda3/condabin/conda config --set auto_activate_base true
RUN /root/miniconda3/condabin/conda update -n base conda -y
RUN /root/miniconda3/condabin/conda install -c conda-forge gdown -y




# Switch directory
WORKDIR /root/

# Copy the project directory from host to container
COPY . /root/




# Extract original datasets

# Download and extract original E2E and WikiBio datasets
RUN mkdir /root/original-datasets/
RUN git clone https://github.com/tuetschek/e2e-dataset.git
RUN git clone https://github.com/DavidGrangier/wikipedia-biography-dataset.git
RUN mv /root/e2e-dataset/ /root/original-datasets/e2e-dataset/
RUN mv /root/wikipedia-biography-dataset/ /root/original-datasets/wikipedia-biography-dataset/
RUN cat /root/original-datasets/wikipedia-biography-dataset/wikipedia-biography-dataset.z* >> /root/original-datasets/wikipedia-biography-dataset/wikipedia-biography-dataset.zip
RUN unzip -o /root/original-datasets/wikipedia-biography-dataset/wikipedia-biography-dataset.zip -d /root/original-datasets/




# Setup Neural Template Generation

# Setup two distinct conda environments, one for GPU utilization and one for CPU only
RUN /root/miniconda3/condabin/conda create --name ntg_gpu python=2.7 regex pytorch=1.0 cudatoolkit=10.0 cudnn=7.3 -y
RUN /root/miniconda3/condabin/conda create --name ntg_cpu -c conda-forge python=2.7 regex pytorch-cpu=1.0 -y

# Fetch code
RUN git clone https://github.com/nbishdev/neural-template-gen

# Extract the pre-processed E2E dataset
RUN tar -xvf /root/neural-template-gen/data/e2e_aligned.tar.gz -C /root/neural-template-gen/data/

# Extract the pre-processed WikiBio dataset
RUN tar -xvf /root/neural-template-gen/data/wb_aligned.tar.gz -C /root/neural-template-gen/data/

# Copy the original WikiBio dataset to the pre-processed dataset directory
RUN cp /root/original-datasets/wikipedia-biography-dataset/train/train.box /root/neural-template-gen/data/wb_aligned/src_train.txt
RUN cp /root/original-datasets/wikipedia-biography-dataset/test/test.box /root/neural-template-gen/data/wb_aligned/src_test.txt
RUN cp /root/original-datasets/wikipedia-biography-dataset/valid/valid.box /root/neural-template-gen/data/wb_aligned/src_valid.txt

# Download pre-trained models
RUN mkdir /root/neural-template-gen/models/
RUN mkdir /root/neural-template-gen/models/original_models/
RUN /root/miniconda3/bin/gdown --id 1kWHE8h0JB7TOAM69dRjBn_LVlXX6bjNN -O /root/neural-template-gen/models/original_models/
RUN /root/miniconda3/bin/gdown --id 1MS7gPsXiGD8FSiHhrLO6GFbWH_0rdgT4 -O /root/neural-template-gen/models/original_models/
RUN /root/miniconda3/bin/gdown --id 1BzCEO-aSK0KTkjbTmPhSvFXK65JYj0xg -O /root/neural-template-gen/models/original_models/
RUN /root/miniconda3/bin/gdown --id 1vbflX3-qPJcnQeURpbGwR3ybxIDUsbRD -O /root/neural-template-gen/models/original_models/

# Extract new models
RUN unzip -o /root/ntg/models.zip -d /root/neural-template-gen/models/

# Extract segs
RUN mkdir /root/neural-template-gen/segs/
RUN /root/miniconda3/bin/gdown --id 1ON4ROs_coDNmVt3-JON4wK1Kc_NkIV2M -O /root/neural-template-gen/segs/
RUN tar -xvf /root/neural-template-gen/segs/segs.tar.gz -C /root/neural-template-gen/segs/
RUN mv /root/neural-template-gen/segs/segs/ /root/neural-template-gen/segs/original_segs/
RUN unzip -o /root/ntg/segs.zip -d /root/neural-template-gen/segs/

# Extract the generations
RUN mkdir /root/neural-template-gen/gens/
RUN unzip -o /root/ntg/gens.zip -d /root/neural-template-gen/gens/
RUN mkdir /root/neural-template-gen/gens_postprocessed/
RUN unzip -o /root/ntg/gens_postprocessed.zip -d /root/neural-template-gen/gens_postprocessed/

# Move the post-process Python script to the proper directory and make it executable
RUN mv /root/ntg/*.py /root/neural-template-gen/gens/
RUN chmod +x /root/neural-template-gen/gens/postprocess_gens_e2e.py

# Move the main execution BASH scripts to the proper directory and make them executable
RUN mv /root/ntg/*.sh /root/neural-template-gen
RUN chmod +x /root/neural-template-gen/ntg_e2e.sh
RUN chmod +x /root/neural-template-gen/ntg_e2e_original.sh
RUN chmod +x /root/neural-template-gen/ntg_wb.sh
RUN chmod +x /root/neural-template-gen/ntg_wb_original.sh




# Setup E2E NLG Challenge Evaluation metrics

# Setup a conda environment
RUN /root/miniconda3/condabin/conda create --name e2e_metrics python=3.6 openjdk=8.0 matplotlib scikit-image future pandas tabulate -y
RUN /root/miniconda3/condabin/conda install --name e2e_metrics -c bioconda perl perl-xml-twig -y

# Fetch code
RUN git clone https://github.com/tuetschek/e2e-metrics

# Extract the output scores
RUN mkdir /root/e2e-metrics/output_scores/
RUN unzip -o /root/e2e/output_scores.zip -d /root/e2e-metrics/output_scores/

# Move the evaluation & display Python scripts to the proper directory and make them executable
RUN mv /root/e2e/*.py /root/e2e-metrics/
RUN chmod +x /root/e2e-metrics/display_scores.py
RUN chmod +x /root/e2e-metrics/measure_scores.py

# Move the main execution BASH scripts to the proper directory and make them executable
RUN mv /root/e2e/*.sh /root/e2e-metrics/
RUN chmod +x /root/e2e-metrics/e2e_metrics_ntg.sh
RUN chmod +x /root/e2e-metrics/e2e_metrics_tgen.sh




# Setup D&J TGen (E2E benchmark)

# Setup a conda environment
RUN /root/miniconda3/condabin/conda create --name tgen python=3.6 tensorflow=1.15 pandas future regex unicodecsv numpy pip -y
RUN /root/miniconda3/condabin/conda install -c conda-forge --name tgen pudb -y

# Fetch code
RUN git clone https://github.com/nbishdev/tgen

# Install all requirements
RUN /root/miniconda3/envs/tgen/bin/pip3 install -r /root/tgen/requirements.txt

# Setup treex, environment variables & path
WORKDIR /root/tgen/
RUN git clone https://github.com/ufal/treex.git
WORKDIR /root/
RUN echo 'export PATH="$HOME/tgen/treex/bin:$PATH"' >> /root/.bashrc
RUN echo 'export PERL5LIB="$HOME/tgen/treex/lib:$PERL5LIB"' >> /root/.bashrc
RUN echo 'export TMT_ROOT=$HOME/.treex' >> /root/.bashrc

# Extract models
RUN mkdir /root/tgen/e2e-challenge/model/
RUN unzip -o /root/tg/model.zip -d /root/tgen/e2e-challenge/model/

# Extract outputs
RUN mkdir /root/tgen/e2e-challenge/output/
RUN unzip -o /root/tg/output.zip -d /root/tgen/e2e-challenge/output/

# Move the main execution BASH scripts to the proper directory and make them executable
RUN mv /root/tg/*.sh /root/tgen/
RUN chmod +x /root/tgen/tgen.sh

# Pre-process the E2E dataset
RUN /root/tgen/tgen.sh -preprocess




# Wiki2Bio (Seq2Seq)

# Setup two distinct conda environments, one for GPU utilization and one for CPU only
RUN /root/miniconda3/condabin/conda create --name w2b_gpu python=2.7 tensorflow-gpu=1.15 nltk pandas tabulate -y
RUN /root/miniconda3/condabin/conda install --name w2b_gpu -c bioconda perl perl-xml-dom perl-db-file -y
RUN /root/miniconda3/condabin/conda create --name w2b_cpu python=2.7 tensorflow=1.15 nltk pandas tabulate -y
RUN /root/miniconda3/condabin/conda install --name w2b_cpu -c bioconda perl perl-xml-dom perl-db-file -y

# Fetch code
RUN git clone https://github.com/tyliupku/wiki2bio

# Download original dataset
RUN /root/miniconda3/bin/gdown --id 15AV8LeWY3nzCKb8RRbM8kwHAp_DUZ5gf -O /root/wiki2bio/original_data/

# Extract the original dataset
RUN unzip -o /root/wiki2bio/original_data/original_data.zip -d /root/wiki2bio/

# Extract the results
RUN mkdir /root/wiki2bio/results/
RUN unzip -o /root/w2b/res.zip -d /root/wiki2bio/results/
RUN unzip -o /root/w2b/evaluation.zip -d /root/wiki2bio/results/

# Make the perl script executable
RUN chmod +x /root/wiki2bio/ROUGE/ROUGE-1.5.5.pl

# Make the Python scripts executable
RUN mkdir /root/wiki2bio/log/
RUN mv /root/w2b/*.py /root/wiki2bio/log/
RUN chmod +x /root/wiki2bio/log/display_test_metrics.py
RUN chmod +x /root/wiki2bio/log/select_best_model.py

# Move the main execution BASH scripts to the proper directory and make them executable
RUN mv /root/w2b/*.sh /root/wiki2bio/
RUN chmod +x /root/wiki2bio/w2b.sh

# Pre-process the WikiBio dataset
RUN mkdir /root/wiki2bio/processed_data/
RUN /root/wiki2bio/w2b.sh -preprocess



 
# Remove unecessary datasets
RUN rm -rf /root/Miniconda3-latest-Linux-x86_64.sh
RUN rm -rf /root/original-datasets/wikipedia-biography-dataset/wikipedia-biography-dataset.z*
RUN rm -rf /root/neural-template-gen/data/e2e_aligned.tar.gz
RUN rm -rf /root/neural-template-gen/data/wb_aligned.tar.gz
RUN rm -rf /root/neural-template-gen/segs.tar.gz
RUN rm -rf /root/ntg/
RUN rm -rf /root/e2e/
RUN rm -rf /root/tg/
RUN rm -rf /root/w2b/
RUN rm -rf /root/wiki2bio/original_data/original_data.zip




# Execute bash shell
CMD ["/bin/bash"]
