# overview

This is an implementation of a tree viewer assignment. Principal source files are:
- `perl/main.pl` for backend
- `tree-view/src/App.vue` and `tree-view/src/Node.vue` for frontend (and `tree-view/src/assets/node.css`)

The `tree-view` folder is created from a Vue install template. Primary source of information for implementing backend was: [https://metacpan.org/dist/Dancer2/view/lib/Dancer2/Tutorial.pod](https://metacpan.org/dist/Dancer2/view/lib/Dancer2/Tutorial.pod)

# requirements
- Frontend: JavaScript (see json packages)
- Backend: Perl with `Dancer2`, `DBI` and `XML::LibXML`
- Database: MySQL with access

# configuration
## Database
- choose a `name` for a database, and the `username` and `password` which will be used to access it
- on your MySQL server, run the following statement: `CREATE DATABASE name;`, with your chosen name
- then, give access rights using: `GRANT ALL PRIVILEGES ON name.* TO 'username'@'localhost' IDENTIFIED BY password;` using the chosen credentials
- enter all of name, username and password into `conf.xml`, the elements `database-name`, `database-username` and `database-pw`, respectively
- finally, execute all statements in `schema.sql` on the database to prepare it


## Frontend
- go to `tree-view` and run `npm install` to install packages
- if your Perl script runs on a port other than 3000, open `tree-view/src/Component.vue` and change port number on line 27

# Running
- ensure your MySQL server is running
- start backend up using `perl perl/main.pl`
- in paralell, start frontend using `npm run dev`. The output should tell you on what localhost address the app becomes available