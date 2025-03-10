# Kubernetes

To install and run Kuma on Kubernetes execute the following steps:

* [1. Download Kuma](#_1-download-kuma)
* [2. Run Kuma](#_2-run-kuma)
* [3. Use Kuma](#_3-use-kuma)

Finally you can follow the [Quickstart](#_4-quickstart) to take it from here and continue your Kuma journey.

::: tip
Kuma also provides [Helm charts](../installation/helm/) that we can use instead of this distribution.
:::

### 1. Download Kuma

To run Kuma on Kubernetes, you need to download a compatible version of Kuma for the machine from which you will be executing the commands.


:::: tabs :options="{ useUrlFragment: false }"
::: tab "Script"

You can run the following script to automatically detect the operating system and download Kuma:

```sh
curl -L https://kuma.io/installer.sh | sh -
```

:::
::: tab "Direct Link"

You can also download the distribution manually. Download a distribution for the **client host** from where you will be executing the commands to access Kubernetes:

* <a :href="'https://download.konghq.com/mesh-alpine/kuma-' + $page.latestVersion + '-centos-amd64.tar.gz'">CentOS</a>
* <a :href="'https://download.konghq.com/mesh-alpine/kuma-' + $page.latestVersion + '-rhel-amd64.tar.gz'">RedHat</a>
* <a :href="'https://download.konghq.com/mesh-alpine/kuma-' + $page.latestVersion + '-debian-amd64.tar.gz'">Debian</a>
* <a :href="'https://download.konghq.com/mesh-alpine/kuma-' + $page.latestVersion + '-ubuntu-amd64.tar.gz'">Ubuntu</a>
* <a :href="'https://download.konghq.com/mesh-alpine/kuma-' + $page.latestVersion + '-darwin-amd64.tar.gz'">macOS</a> or run `brew install kumactl`

and extract the archive with:

```sh
tar xvzf kuma-*.tar.gz
```

:::
::::

### 2. Run Kuma

Once downloaded, you will find the contents of Kuma in the `kuma-{{ $page.latestRelease }}` folder. In this folder, you will find - among other files - the `bin` directory that stores the executables for Kuma, including the CLI client [`kumactl`](../documentation/cli/#kumactl).

::: tip
**Note**: On Kubernetes - of all the Kuma binaries in the `bin` folder - we only need `kumactl`.
:::

So we enter the `bin` folder by executing:

```sh
cd kuma-*/bin
```

Finally we can install and run Kuma in either **standalone** or **multi-zone** mode:

:::: tabs :options="{ useUrlFragment: false }"
::: tab "Standalone"

Standalone mode is perfect when running Kuma in a single cluster across one environment:

```sh
./kumactl install control-plane | kubectl apply -f -
```

To learn more, read about the [deployment modes available](../documentation/deployments/).

:::
::: tab "Multi-Zone"

Multi-zone mode is perfect when running one deployment of Kuma that spans across multiple Kubernetes clusters, clouds and VM environments under the same Kuma deployment. 

This mode also supports hybrid Kubernetes + VMs deployments.

To learn more, read the [multi-zone installation instructions](../documentation/deployments/).

:::
::::


We suggest adding the `kumactl` executable to your `PATH` so that it's always available in every working directory. Or - alternatively - you can also create link in `/usr/local/bin/` by executing:

```sh
ln -s $PWD/kumactl /usr/local/bin/kumactl
```

::: tip
It may take a while for Kubernetes to start the Kuma resources, you can check the status by executing:

```sh
kubectl get pod -n kuma-system
```
:::

### 3. Use Kuma

Kuma (`kuma-cp`) will be installed in the newly created `kuma-system` namespace! Now that Kuma has been installed, you can access the control-plane via either the GUI, `kubectl`, the HTTP API, or the CLI:

:::: tabs :options="{ useUrlFragment: false }"
::: tab "GUI (Read-Only)"

Kuma ships with a **read-only** GUI that you can use to retrieve Kuma resources. By default the GUI listens on the API port and defaults to `:5681/gui`. 

To access Kuma we need to first port-forward the API service with:

```sh
kubectl port-forward svc/kuma-control-plane -n kuma-system 5681:5681
```

And then navigate to [`127.0.0.1:5681/gui`](http://127.0.0.1:5681/gui) to see the GUI.

:::
::: tab "kubectl (Read & Write)"

You can use Kuma with `kubectl` to perform **read and write** operations on Kuma resources. For example:

```sh
kubectl get meshes
# NAME          AGE
# default       1m
```

or you can enable mTLS on the `default` Mesh with:

```sh
echo "apiVersion: kuma.io/v1alpha1
kind: Mesh
metadata:
  name: default
spec:
  mtls:
    enabledBackend: ca-1
    backends:
    - name: ca-1
      type: builtin" | kubectl apply -f -
```

:::
::: tab "HTTP API (Read-Only)"

Kuma ships with a **read-only** HTTP API that you can use to retrieve Kuma resources.

By default the HTTP API listens on port `5681`. To access Kuma we need to first port-forward the API service with:

```sh
kubectl port-forward svc/kuma-control-plane -n kuma-system 5681:5681
```

And then you can navigate to [`127.0.0.1:5681`](http://127.0.0.1:5681) to see the HTTP API.

:::
::: tab "kumactl (Read-Only)"

You can use the `kumactl` CLI to perform **read-only** operations on Kuma resources. The `kumactl` binary is a client to the Kuma HTTP API, you will need to first port-forward the API service with:

```sh
kubectl port-forward svc/kuma-control-plane -n kuma-system 5681:5681
```

and then run `kumactl`, for example:

```sh
kumactl get meshes
# NAME          mTLS      METRICS      LOGGING   TRACING
# default       off       off          off       off
```

You can configure `kumactl` to point to any zone `kuma-cp` instance by running:

```sh
kumactl config control-planes add --name=XYZ --address=http://{address-to-kuma}:5681
```
:::
::::

You will notice that Kuma automatically creates a [`Mesh`](../../policies/mesh) entity with name `default`.

### 4. Quickstart

Congratulations! You have successfully installed Kuma on Kubernetes 🚀. 

In order to start using Kuma, it's time to check out the [quickstart guide for Kubernetes](../quickstart/kubernetes/) deployments.
