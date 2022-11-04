FROM msharrock/deepbleed:latest

#Rerplace the original predict.py
COPY predict.py /deepbleed/predict.py

#Download weights in the /weights folder
RUN mkdir /weights && \
    cd /weights &&\
    wget -O weights.zip https://www.dropbox.com/s/v2ptd9mfpo13gcb/mistie_2-20200122T175000Z-001.zip?dl=1 && \
    unzip -j weights.zip &&\
    for i in _data-00001-of-00002 _data-00000-of-00002 _index;
    do
        out=`echo ${i} | sed "s/_/weights./"`;
        mv ${i} ${out};
    done

