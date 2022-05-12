#!/bin/bash
 
########################################################################
#Script Name    :analize_chart.sh                                                                                             
#Version        :0.1 (beta)
#Description    :report cluster/namespace scoped resources in a chart                                                                                 
#Args           :read from stdin rendered k8s resources
#Author         :David Palau                                              
#Example        :
# Set your context/namespace acordly to your need
# helm template mykafka-instance bitnami/kafka \
# --version 14.2.5 -f values.yaml | analize_chart.sh   
########################################################################
 
eval_scope() {
    clusterResources=""
    namespaceResources=""
    for item in $data
    do
        api=$(echo "$item" | cut -d'|' -f 1)
        kind=$(echo "$item" | cut -d'|' -f 2)
        name=$(echo "$item" | cut -d'|' -f 3)
        echo $namespaceObjects | grep -w -q $kind && printf -v namespaceResources "$namespaceResources\n- $name (${kind})" || printf -v clusterResources "$clusterResources\n- $name (${kind})"
             
    done
    echo -n "Cluster-wide resources:"
    [[ -z $clusterResources ]] && echo "None" || echo "$clusterResources"
    echo -n "Namespaced resources:"
    [[ -z $namespaceResources ]] && echo "None" || echo "$namespaceResources"
 
}
 
eval_crd_conflicts() {
    prospect_crd=$(echo "$data" | grep CustomResourceDefinition)
    created_crd=$(kubectl get customresourcedefinitions.apiextensions.k8s.io -o name | cut -d "/" -f 2)
    crd_conflicts=""
    for item in $prospect_crd
    do
        api=$(echo "$item" | cut -d'|' -f 1)
        name=$(echo "$item" | cut -d'|' -f 3)      
        echo $created_crd | grep -w -q $name \
            && printf -v crd_conflicts "$crd_conflicts\n- $name ($api) already exists"
    done
    echo -n "CRD conflicts:"
    [[ -z $crd_conflicts ]] && echo "None" || echo "$crd_conflicts"
}
 
eval_naming_conflicts() {
    naming_conflicts=""
    for item in $data
    do
        api=$(echo "$item" | cut -d'|' -f 1)
        kind=$(echo "$item" | cut -d'|' -f 2)
        name=$(echo "$item" | cut -d'|' -f 3)      
        kubectl get $kind $name > /dev/null 2>&1  \
            && printf -v naming_conflicts "$naming_conflicts\n- $name ($kind) already exists"
    done
    echo -n "Naming conflicts(namespace=$currentNamespace):"
    [[ -z $naming_conflicts ]] && echo "None" || echo "$naming_conflicts"  
 
}
input=$(</dev/stdin)
data=$(echo "$input" | yq '.apiVersion + "|" + .kind + "|" + .metadata.name' | grep -v ^---)
 
namespaceObjects=$(kubectl api-resources --namespaced=true --no-headers | rev | cut -d " " -f 1 | rev)
currentNamespace=$(kubectl config view --minify -o jsonpath='{..namespace}' || { printf "\n>>>Select a valid context<<<\n";exit -1; })
 
eval_scope
eval_crd_conflicts
eval_naming_conflicts
