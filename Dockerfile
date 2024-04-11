FROM python:3-alpine as builder

ENV PATH="/opt/.env/bin:${PATH}"

COPY ./api/ /app

RUN \
  apk update && \
  apk add build-base && \
  python -m venv /opt/.env && \
  pip install --upgrade pip && \
  pip install -r /app/requirements.txt

FROM python:3-alpine

ARG UID=1005
ARG USERNAME=flask

COPY --from=builder /opt/.env /opt/.env
COPY --from=builder /app /app

ENV PATH="/opt/.env/bin:${PATH}"

RUN \
  apk update && \
  adduser -g ${USERNAME} ${USERNAME} --disabled-password --uid ${UID} && \
  chown -R ${USERNAME} /app

EXPOSE 5000
WORKDIR /app

USER ${USERNAME}

ENTRYPOINT ["python", "app.py"]
