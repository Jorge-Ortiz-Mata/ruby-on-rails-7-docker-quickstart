FROM ruby:3.0.4 as base

RUN apt-get update -qq \
    && apt-get install -y nodejs \
    ca-certificates \
    curl \
    sudo \
    postgresql-client \
    imagemagick \
    libvips

WORKDIR /workspaces/myapp

FROM base as development

USER root

ARG USERNAME=jorge
ARG USER_UID=1001
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && usermod -aG sudo $USERNAME \
    && sudo chown -R $USERNAME:$USERNAME .

RUN apt-get update

COPY Gemfile .
COPY Gemfile.lock .

RUN bundle install

COPY . .

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

USER $USERNAME

CMD [ "puma" ]
