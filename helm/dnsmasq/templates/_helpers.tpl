{{- define "iot-dnsmasq.fullname" -}}
{{- $name := default .Chart.Name .Values.fullnameOverride -}}
{{- printf "%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "iot-dnsmasq.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "iot-dnsmasq.labels" -}}
helm.sh/chart: {{ include "iot-dnsmasq.chart" . }}
iotedge.intel.com/appname: dnsmasq
{{- end -}}

{{- define "iot-dnsmasq.args" -}}
{{- if .Values.only_tftp -}}
- -O
{{- else -}}
- -i {{ .Values.network.interface }}
- -D {{ .Values.remote_dns }}
- -r {{ .Values.pxe_server }}
- -n {{ .Values.tink_domain }}
{{- if .Values.dns.enable }}
- -d
{{- end -}}
{{ if .Values.tftp.enable }}
- -f
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "iot-dnsmasq.registry-url" -}}
{{- if .Values.image.registry -}}
{{- printf "docker://%s/" .Values.image.registry -}}
{{- end -}}
{{- printf "%s:" .Values.image.repository -}}
{{- .Values.image.tag -}}
{{- end -}}


{{- define "iot-dnsmasq.container-volumes" -}}
{{- if .Values.dns.enable -}}
- name: dnsconf
  mountPath: /home/iotedge/dnsmasq.d
{{- end -}}
{{- end -}}

{{- define "iot-dnsmasq.volumes" -}}
{{- if .Values.dns.enable -}}
- name: dnsconf
  configMap:
    name: dnsconf
{{- end -}}
{{- end -}}


{{- define "iot-dnsmasq.domain-name" -}}
{{- range .Values.dns.domains -}}
address=/{{ .name }}/{{ .value }}{{- "\n" -}}
{{- end -}}
{{- end -}}

