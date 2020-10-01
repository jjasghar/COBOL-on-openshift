# COBOL on OpenShift

## Scope

**This is an NOT production ready, this is just a experiment**

This repository shows off a simple [ETL pipeline](https://databricks.com/glossary/etl-pipeline) using
COBOL and OpenShift.

There are two main portions to this repository. The [docker-containers](./docker-containers) holds the
configuration and repeatable builds of the different containers of the ETL pipeline. The [OpenShift](./os)
directory has the `.yaml` file to deploy the said containers to a OpenShift cluster on [IBM Cloud](https://cloud.ibm.com).

The demo COBOL applicaiton is located [here](./plus5numbers.cbl). It is a simple COBOL application
that takes in a file called `numbers.txt` (an [example](./numbers.txt.example) here) and outputs a
file called `newNumbers.txt` with every number rewritten 5 added to it. If you take a look at the
diagram below you see the pipeline illustrated.

> TODO Image of the pipeline

## Demoing it Yourself
### Pre-Requisites

- An s3 bucket like Cloud Object Storage on IBM Cloud
- `s3fs` installed on the machine to upload a `numbers.txt`
- `docker` if you want to build the containers
- An OpenShift cluster like the OpenShift Service on IBM Cloud
- Edit the `local.env.example` and save it as `local.env` for the needed `exports`

### Object storage

Create a an object storage instance, for instance `asgharlabs-cobol`. Then created a bucket, for instance `asgharlabs-cobol-in` that you can put a file into it. Set it to `Public` access also, so you can download from it directly.

Steps make the bucket public: [example](https://s3.sjc04.cloud-object-storage.appdomain.cloud/asgharlabs-in/numbers.txt)

- Choose the bucket that you want to be publicly accessible. Keep in mind this policy makes all objects in a bucket available to download for anyone with the appropriate URL.
- Select Access policies from the navigation menu.
- Select the Public access tab.
- Click Create access policy. After you read the warning, choose Enable.
- Now all objects in this bucket are publicly accessible!

To create a Service account:
- Log in to the IBM Cloud console and navigate to your instance of Object Storage.
- In the side navigation, click Service Credentials.
- Click New credential and provide the necessary information. If you want to generate HMAC credentials, click 'Include HMAC Credential' check box
- Click Add to generate service credential.

Expanded the `View Credentials` and found the `access_key_id` and `secret_access_key` and put them
in a file with `access_key_id:secret_access_key` format.

Example of using `s3fs` to mount the local directory.

```bash
s3fs asgharlabs-in s3/ -o url=https://s3.sjc04.cloud-object-storage.appdomain.cloud -o passwd_file=key.key
```

### Steps to Run the Demo

#### Building from Prebuilt Containers

- Create an OpenShift cluster and connect to it via the `oc` command. If you don't know how to, follow [this link](https://learn.openshift.com/introduction/cluster-access/).
- Create a new project to isolate this from other things running on your OpenShift instance
```bash
oc new-project cobol-on-os
```
- Deploy the _public_ pods (from docker hub `jjasghar`)
```bash
cd os
oc create -f cobol.yaml
```

#### Bulding from Source

- Go into the `docker-containers/` directory on the local machine
- Create build for each of the containers. You'll need to point them to your `s3` bucket.
```bash
oc new-app . --context-dir=cobol-batch/ --name=cobol-batch
oc new-app . --context-dir=watcher-in/ --name=watcher-in
oc new-app . --context-dir=watcher-out/ --name=watcher-out
OR
cd cobol-batch && docker build . -tag <yourdockerhub>/cobol-batch:latest && docker push <yourdockerhub>/cobol-batch:latest && cd ..
cd watcher-in && docker build . -tag <yourdockerhub>/watcher-in:latest && docker push <yourdockerhub>/watcher-in:latest && cd ..
cd watcher-out && docker build . -tag <yourdockerhub>/watcher-out:latest && docker push <yourdockerhub>/wacher-out:latest && cd ..
```
- Create a `deployment.yaml` like the [cobol.yaml](os/cobol.yaml) example we have.
- Deploy and it should start the pipeline when it finds the file in the `s3` bucket.

## License & Authors

If you would like to see the detailed LICENSE click [here](./LICENSE).

- Author: JJ Asghar <awesome@ibm.com>

```text
Copyright:: 2019- IBM, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
