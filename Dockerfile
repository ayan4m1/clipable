FROM golang:alpine AS backend-build

ENV CGO_ENABLED=0
ENV GOOS=linux

WORKDIR /app
COPY backend/ .
RUN go build -o clipable

FROM jitesoft/node-yarn:iron AS frontend-builder
WORKDIR /home/node/app
COPY frontend/.npmr[c] ./

COPY frontend/ .
RUN yarn install
RUN npm run build

FROM node:alpine

WORKDIR /clipable
RUN apk add --update --no-cache nginx supervisor

ENV NODE_ENV production

COPY --from=frontend-builder /home/node/app/next.config.js ./
COPY --from=frontend-builder /home/node/app/public ./public
COPY --from=frontend-builder /home/node/app/package.json ./package.json

# Automatically leverage output traces to reduce image size 
# https://nextjs.org/docs/advanced-features/output-file-tracing
# Some things are not allowed (see https://github.com/vercel/next.js/issues/38119#issuecomment-1172099259)
COPY --from=frontend-builder /home/node/app/.next/standalone ./
COPY --from=frontend-builder /home/node/app/.next/static ./.next/static

COPY --from=mwader/static-ffmpeg:7.0.1 /ffmpeg /usr/local/bin/
COPY --from=mwader/static-ffmpeg:7.0.1 /ffprobe /usr/local/bin/

COPY backend/migrations ./migrations
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY --from=backend-build /app/clipable ./
COPY ./supervisord.conf ./supervisord.conf

ENTRYPOINT ["supervisord", "-c", "./supervisord.conf"]
