FROM nginx:1.23
# Set the working directory
WORKDIR /usr/share/nginx/html
# Expose ports
EXPOSE 80
EXPOSE 443
# Set the entrypoint
ENTRYPOINT ["nginx", "-g", "daemon off;"]
