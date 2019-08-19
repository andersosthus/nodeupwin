Forked from https://github.com/microsoft/SDN/tree/master/Kubernetes/windows

# How to deploy Kubernetes on Windows

The start scripts in this directory are just a reference to get started, and primarily intended for experimentation and development. They use [wincni](./cni/) as the container networking plugin in l2bridge mode. It assumes you have manually programmed [static routes](https://docs.microsoft.com/en-us/virtualization/windowscontainers/kubernetes/configuring-host-gateway-mode) using [AddRoutes.ps1](./AddRoutes.ps1) scripts, on each Windows node. Please see our [Getting Started Guide](https://docs.microsoft.com/en-us/virtualization/windowscontainers/kubernetes/getting-started-kubernetes-windows) for more detailed step-by-step instructions on how to bootstrap a Kubernetes cluster.
