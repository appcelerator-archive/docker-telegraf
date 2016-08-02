From appcelerator/alpine:3.4.0
RUN echo "http://nl.alpinelinux.org/alpine/v3.4/community" >> /etc/apk/repositories 
RUN apk --update add docker
COPY ./test.sh /bin
CMD ["/bin/test.sh"]
