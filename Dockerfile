FROM ubuntu:24.04 AS build
RUN apt-get update && apt-get install -y curl git unzip xz-utils zip libglu1-mesa ca-certificates && rm -rf /var/lib/apt/lists/*
RUN git clone --depth 1 -b stable https://github.com/flutter/flutter.git /opt/flutter
ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:${PATH}"
WORKDIR /app
COPY . .
RUN flutter config --enable-web && flutter pub get && dart run build_runner build --delete-conflicting-outputs && flutter build web --release
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
