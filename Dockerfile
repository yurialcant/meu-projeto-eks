# Usar a imagem oficial do Nginx
FROM nginx:alpine

# Remover o index.html padrão
RUN rm /usr/share/nginx/html/index.html

# Adicionar uma página de "Hello World" customizada
COPY index.html /usr/share/nginx/html/index.html