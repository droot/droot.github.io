# About Me

I am a software engineer at Google. I work on the GKE team at Google Cloud.

I co-authored the following projects in the Kubernetes space:

- **[kustomize](https://github.com/kubernetes-sigs/kustomize)**: template free kubernetes config customization tool
- **[kubebuilder](https://github.com/kubernetes-sigs/kubebuilder)**: Go SDK for kubernetes APIs and controllers
- **[kubectl-ai](https://github.com/GoogleCloudPlatform/kubectl-ai)**: An AI agent for everything kubernetes

## Blog

<ul>
  {% for post in site.posts %}
    <li>
      <a href="{{ post.url | relative_url }}">{{ post.title }}</a>
      <span style="font-size: smaller; color: #777;">- {{ post.date | date: "%B %-d, %Y" }}</span>
    </li>
  {% endfor %}
</ul>
