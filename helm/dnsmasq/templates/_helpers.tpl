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
- -i {{ .Values.network.interface }}
- -s {{ .Values.dhcp.range_min }}
- -e {{ .Values.dhcp.range_max }}
- -a {{ .Values.network.ip }}
-
{{- printf " -n %s\n" .Values.tink_domain -}}
{{- if .Values.dns.enable -}}
{{- printf "- -d\n" -}}
{{- end -}}
{{- if .Values.tftp.enable -}}
{{- printf "- -f" -}}
{{- end -}}
{{- end -}}

{{- define "iot-dnsmasq.registry-url" -}}
{{- if .Values.image.registry -}}
{{- printf "docker://%s/" .Values.image.registry -}}
{{- end -}}
{{- printf "%s:" .Values.image.repository -}}
{{- .Values.image.tag -}}
{{- end -}}

