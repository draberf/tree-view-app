<template>

  <!-- show Node if tree is loaded -->
  <div v-if="hasTree">
    <Node :node="this.tree" />
  </div>

  <!-- show error message if entry incorrect -->
  <div style="color:red">{{ errMessage }}</div>

  <!-- form to add new node to parent ID -->
  <div>
    Add Node To:
    <input v-model="pid">PID</input>
    <button @click="add_node">Add node</button>
  </div>
</template>

<script>
  import axios from 'axios';
  import Node from './Node.vue';
  
  export default {
    components: {
      Node
    },
    data() {
      return {
        message: "Loading...",
        tree: null,
        errMessage: "",
        pid: "",
        port:"3000"
      };
    },
    methods: {
      // POST request to attach a child node to a given ID
      // requires <input> to be an integer that exists in the tree
      add_node(event) {
        if (this.pid != Number.parseInt(this.pid)) {
          this.errMessage = "PID must be an integer.";
          return;
        }
        axios.post('http://localhost:'+this.port+'/add_node', "tree_id=1&parent_id="+this.pid)
        .then(response => {
          this.tree = response.data;
        })
        .catch(error => {
          console.error("There was an error fetching the data!", error);
        });
      },
      hasTree() { return !(this.tree === null); } 
    },
    created() {
      // get tree of ID 1 to display
      axios.get('http://localhost:'+this.port+'/get_tree/1')
        .then(response => {
          this.tree = response.data;
        })
        .catch(error => {
          console.error("There was an error fetching the data!", error);
        });
    }
  };
  </script>