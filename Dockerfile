FROM msharrock/deepbleed:latest

#Rerplace the original predict.py
ADD predict.py /deepbleed/predict.py
ADD command.json /
#Download weights in the /weights folder
RUN mkdir /weights && \
    cd /weights &&\
    wget -O weights.zip https://www.dropbox.com/s/v2ptd9mfpo13gcb/mistie_2-20200122T175000Z-001.zip?dl=1 && \
    unzip -j weights.zip &&\
    for i in _data-00001-of-00002 _data-00000-of-00002 _index; \
    do \
        out=`echo ${i} | sed "s/_/weights./"`; \
        mv ${i} ${out}; \
    done

#For some reason the original dockerfile does not copy templates
RUN cd /deepbleed && \
    wget https://github.com/msharrock/deepbleed/raw/master/icbm152_t1_tal_nlin_asym_09c_masked.nii.gz && \
    wget https://github.com/msharrock/deepbleed/raw/master/ct2mni.mat

WORKDIR /deepbleed

CMD ["bash", "-c", "source /etc/bash.bashrc"]

LABEL org.nrg.commands="{\"name\":\"deepbleed\",\"description\":\"Runs deepbleed\",\"label\":\"deepbleed\",\"info-url\":\"https://github.com/msharrock/deepbleed\",\"version\":\"1.0\",\"schema-version\":\"0.1\",\"type\":\"docker\",\"image\":\"msharrock/deepbleed\",\"override-entrypoint\":true,\"command-line\":\"python predict.py --indir /input --outdir /output --weights /weights/weights_index\",\"mounts\":[{\"name\":\"in\",\"writable\":\"true\",\"path\":\"/input\"},{\"name\":\"nifti-out\",\"writable\":\"true\",\"path\":\"/output\"}],\"inputs\":[],\"outputs\":[{\"name\":\"nifti\",\"description\":\"The nifti files\",\"mount\":\"nifti-out\",\"required\":\"true\"}],\"xnat\":[{\"name\":\"deepbleed-scan\",\"description\":\"Run deepbleed on a Scan\",\"label\":\"deepbleed\",\"contexts\":[\"xnat:imageScanData\"],\"external-inputs\":[{\"name\":\"scan\",\"description\":\"Input scan\",\"type\":\"Scan\",\"required\":true,\"matcher\":\"'NIFTI' in @.resources[*].label\"}],\"derived-inputs\":[{\"name\":\"scan-nifti\",\"description\":\"The Nifti resource on the scan\",\"type\":\"Resource\",\"derived-from-wrapper-input\":\"scan\",\"provides-files-for-command-mount\":\"in\",\"matcher\":\"@.label == 'NIFTI'\"}],\"output-handlers\":[{\"name\":\"nifti-resource\",\"accepts-command-output\":\"nifti\",\"as-a-child-of-wrapper-input\":\"scan\",\"type\":\"Resource\",\"label\":\"NIFTI_MASK\"}]}]}"
