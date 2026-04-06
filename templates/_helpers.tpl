{{- define "global.domain" -}}{{ .Values.global.domain | default "demo.quximo.com" }}{{- end -}}
{{- define "global.email" -}}{{ .Values.global.email | default "cloud@quximo.com" }}{{- end -}}
{{- define "global.metallb.pool" -}}{{ .Values.global.metallb.pool | default "192.168.100.110-192.168.100.120" }}{{- end -}}
{{- define "global.storage.class" -}}{{ .Values.global.storage.class | default "openebs-hostpath" }}{{- end -}}
