CREATE TABLE IF NOT EXISTS trees (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(32) NOT NULL,
    parent_id INTEGER
);

INSERT IGNORE INTO trees VALUES (1, 'tree', 1);

CREATE TABLE IF NOT EXISTS nodes (
    tree INTEGER NOT NULL,
    id INTEGER,
    parent INTEGER NOT NULL,
    FOREIGN KEY (tree) REFERENCES trees(id),
    PRIMARY KEY (tree, id)
);

INSERT IGNORE INTO nodes VALUES (1, 1, -1);