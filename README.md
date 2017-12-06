# docker-zap-elk

<img src="zap-proxy.gif?raw=true" width="1080px">

Automated Security Tests via Dockerised Owasp-Zap and zap-cli, Results in Kibana.

You can integrate results with your own reporting tool. It creates a **html**,**xml** and a **json** file. Therefore, CI tool integration is easy.

## Requirements

------------

* Docker
* Docker-compose

## Usage

------------

Just pass URL Parameter to the script. The scan can take more than 30 mins. because of the web crawler (Spider).

```shell
./run-docker.sh https://www.example.com/
```

* Kibana is running on port 5601. just browse : http://localhost:5601

* Import `view.json` to your kibana in order to see a good dashboard. (Optional)

------------

Inspired from this project : https://github.com/stephendonner/docker-zap