FROM alpine:3.4

# add files
ADD ./run.sh /app/run.sh
ADD ./fleet-ui /app/fleet-ui
ADD angular/dist /app/public

# set workdir
WORKDIR /app

# export port
EXPOSE 3000

# run!
ENTRYPOINT ["/app/run.sh"]
