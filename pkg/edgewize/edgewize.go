package edgewize

import (
	"context"
	"k8s.io/klog"
	"sync"

	corev1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/types"
	"sigs.k8s.io/controller-runtime/pkg/client"
)

var fakenodes = &sync.Map{}

func IsSystemWorkspace(cli client.Client, name string) (bool, error) {
	namespace := &corev1.Namespace{}
	err := cli.Get(context.Background(), types.NamespacedName{Name: name}, namespace)
	if err != nil {
		return false, err
	}
	return namespace.Labels["kubesphere.io/workspace"] == "system-workspace", nil
}

func IsFakeNode(cli client.Client, name string) (bool, error) {
	if _, ok := edgewize.FakeNodes.Load(node.Name); ok {
		return true, nil
	}
	node := &corev1.Node{}
	err := cli.Get(context.Background(), types.NamespacedName{Name: name}, node)
	if err != nil {
		klog.Errorf("failed to get node %s: %v", name, err)
		return false, err
	} else {
		if node.Labels["vcluster.loft.sh/fake-node"] == "true" {
			klog.Errorf("node is not fake node, but has label %s", name)
		}
	}
	return false, nil
}

func AddFakeNode(name string) {
	fakenodes.Store(name, struct{}{})
}
