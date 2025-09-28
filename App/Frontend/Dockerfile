
FROM nginx:alpine


RUN rm -rf /usr/share/nginx/html/*

# Copy our frontend files
COPY . /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
