package edgewize

import (
	"context"
	"sync"

	corev1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/types"
	"sigs.k8s.io/controller-runtime/pkg/client"
)

var FakeNodes = &sync.Map{}

func IsSystemWorkspace(cli client.Client, name string) (bool, error) {
	namespace := &corev1.Namespace{}
	err := cli.Get(context.Background(), types.NamespacedName{Name: name}, namespace)
	if err != nil {
		return false, err
	}
	return namespace.Labels["kubesphere.io/workspace"] == "system-workspace", nil
}

func IsFakeNode(cli client.Client, name string) (bool, error) {
	node := &corev1.Node{}
	err := cli.Get(context.Background(), types.NamespacedName{Name: name}, node)
	if err != nil {
		return false, err
	}
	return node.Labels["vcluster.loft.sh/fake-node"] == "true", nil
}
