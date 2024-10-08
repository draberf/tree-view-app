#!/usr/bin/perl
use warnings;
use Dancer2;
use DBI;
use File::Slurper qw/ read_text /;

use XML::LibXML;

# configure
my $conf = XML::LibXML->load_xml(location => './conf.xml');
my $db_name  = $conf->find('configuration/database-name');
my $username = $conf->find('configuration/database-username');
my $password = $conf->find('configuration/database-pw');


# database connection subroutines
sub connect_db {
    return DBI->connect(
        "DBI:mysql:database=$db_name;host=localhost",
        "$username",
        "$password",
        { RaiseError => 1, AutoCommit => 1 }) or die $DBI::errstr;
}

# database actions subroutines
sub check_if_tree_exists {
    my ($dbh, $id) = @_;

    # check if tree even exists
    my $sth = $dbh->prepare(
        "SELECT * FROM trees WHERE trees.id=$id;"
    ) or die "prepare statement failed: $dbh->errstr()";
    $sth->execute() or die "execution failed: $dbh->errstr()";

    unless ($sth->fetch()) {
        return -1;
    }

    return 0;
}

sub get_tree {
    my ($dbh, $id) = @_;

    my $sth = $dbh->prepare(
        "SELECT nodes.id, nodes.parent FROM nodes INNER JOIN trees ON trees.id=nodes.tree WHERE trees.id=$id;"
    ) or die "prepare statement failed: $dbh->errstr()";

    $sth->execute() or die "execution failed: $dbh->errstr()";

    my $hashref = $sth->fetchall_hashref('id');

    # sort tree out


    return $hashref;
}

sub request_tree {
    my ($dbh, $id) = @_;

    unless (check_if_tree_exists($dbh, $id) == 0) {
        return -1;
    }

    my $tree_ref = get_tree($dbh, $id);
    
    # transform tree
    my %transformed_tree = parse_tree_from_nodes(%{$tree_ref});

    return \%transformed_tree;
}

# call on a {id => x, children => []} hash reference
sub add_children {
    my ($parent_ref, %parent_hash) = @_;

    my $parent_id = $parent_ref->{id};

    foreach my $child_id (@{$parent_hash{$parent_id}}) {
        push @{$parent_ref->{children}}, {id => $child_id, children => []};
        add_children(${$parent_ref->{children}}[-1], %parent_hash);
    }
}

# tree operations
sub parse_tree_from_nodes {
    my (%tree) = @_;

    # check if tree_hash is empty
    unless (keys %tree) {
        return {};
    }

    # step 1: create hash with parent_id -> arrays
    my %sorted_by_parent = ( -1 => [] );
    foreach my $id (keys %tree) {
        $sorted_by_parent{$id} = [];
    }

    # tree hash contains node -> <hash representing a node>
    foreach my $node (values %tree) {
        my $parent_id = $node->{parent};
        push @{$sorted_by_parent{$parent_id}}, $node->{id};
    }

    my $root_id = $sorted_by_parent{-1}[0];

    my %actual_tree = (
        id => $root_id,
        children => []
    );

    add_children(\%actual_tree, %sorted_by_parent);

    return %actual_tree;
}

hook 'before' => sub {
    response_header 'Access-Control-Allow-Origin' => '*';
};

get '/' => sub {
    return "Hello world!";
};

get '/get_tree/:id' => sub {
    
    # get tree id
    my $id = param('id');

    my $dbh = connect_db();

    my $tree = request_tree($dbh, $id);

    if ($tree == -1) {
        send_error("Tree with id $id does not exist.", 404);
    }

    return to_json($tree);

};

post '/add_node' => sub {
    my $tree_id = body_parameters->get('tree_id');
    my $parent_id = body_parameters->get('parent_id');
    
    my $dbh = connect_db();

    # get tree
    if (check_if_tree_exists($dbh, $tree_id) == -1) {
        send_error("Tree with id $tree_id does not exist.", 403);
    }

    my $tree = get_tree($dbh, $tree_id);

    # get next node id
    my $tree_size = keys %$tree;
    my $node_id = $tree_size + 1;

    my $sth = $dbh->prepare(
        "INSERT INTO nodes VALUES ($tree_id, $node_id, $parent_id);"
    );

    $sth->execute() or die "execution failed: $dbh->errstr()";

    my $new_tree = request_tree($dbh, $tree_id);
    return to_json($new_tree);
};

start;