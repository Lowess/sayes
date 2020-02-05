# :blush: Sayes - (Say yes!)

> A Simple Nginx server always happy to return 200 responses

Offers a webserver that you can blast while testing callbacks. Similar to [HttpBin](https://httpbin.org/), but more basic.

```
#--prod--
docker run -it --rm \
    -p 8000:80 \
    lowess/sayes
```

## Kubernetes helm chart deployment

```bash
h3 install sayes k8s/sayes \
  --set ingress.hosts="{sayes.domain.com}"
```
