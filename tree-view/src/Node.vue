<template>
<div class="node">
    <div class="node_header">
        {{ node.id }}
    </div>
    <div v-if="hasChildren" class="node_children">
        <Node v-for="child in node.children" :key="child.id" :node="child" />
    </div>
</div>
</template>

<script>
export default {
    name: 'Node',
    props: {
        node: {
            type: Object
        }
    },
    computed: {
        hasChildren() {
            const { children } = this.node
            return children && children.length > 0
        }
    }
}
</script>