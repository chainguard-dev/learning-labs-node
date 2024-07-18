FROM cgr.dev/chainguard/node:latest AS builder

ENV NODE_ENV production

WORKDIR /usr/src/app

RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=package-lock.json,target=package-lock.json \
    --mount=type=cache,target=/root/.npm \
    npm ci --omit=dev

USER node

COPY server.js .
COPY public ./public

FROM cgr.dev/chainguard/node:latest

COPY --from=builder --chown=node:node /usr/src/app /app
EXPOSE 3000
ENV NODE_ENV=production
ENV PATH=/app/node_modules/.bin:$PATH
WORKDIR /app
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["node", "server.js"]
