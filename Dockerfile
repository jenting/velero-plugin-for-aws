# Copyright 2021 the Velero contributors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
FROM --platform=$BUILDPLATFORM golang:1.15 AS build

ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

ENV GOOS=${TARGETOS} \
    GOARCH=${TARGETARCH} \
    GOARM=${TARGETVARIANT}

COPY . /go/src/velero-plugin-for-aws

WORKDIR /go/src/velero-plugin-for-aws

RUN export GOARM=$(echo "${GOARM}" | cut -c2-) && \
    CGO_ENABLED=0 go build -v -o /go/bin/velero-plugin-for-aws ./velero-plugin-for-aws


FROM ubuntu:focal

LABEL maintainer="Nolan Brubaker <brubakern@vmware.com>"

RUN mkdir /plugins

COPY --from=build /go/bin/velero-plugin-for-aws /plugins/

USER nobody:nogroup

ENTRYPOINT ["/bin/bash", "-c", "cp /plugins/* /target/."]
