# Wiki on OpenShift

This git repository helps you to set-up the node.js version of the Smallest Federated Wiki on OpenShift.

## Running on OpenShift

It is simple to create a Federated Wiki site using either the OpenShift command line tools, or the Web
Interface.

We use [https://github.com/ramr/nodejs-custom-version-openshift](custom Node.js version quickstart) to
control the version of node.js, and associated npm version, as the OpenShift version is not always up to date.

### Creating using the command line

Create an account at http://openshift.redhat.com/ and set up your local machine with the client tools.

Create a node-0.10 application (you can call your application whatever you want, we use wiki in this example)
```cmd
  rhc app create wiki nodejs-0.10
```

Add this upstream Wiki Quickstart repo
```cmd
  cd wiki
  git remote add upstream -m master https://github.com/paul90/wiki-openshift-quickstart.git
  git pull -s recursive -X theirs upstream master
```

This can then be pushed to Openshift
```cmd
  git push
```

N.B. This first `git push` will take a while to complete as it has to install all
the wiki packages, and their dependencies.

That's it, you can now checkout your application at:
```
  http://wiki-$yournamespace.rhcloud.com
```
One of the first things you will want to do is to claim your site.

## Keeping up to date

### Updating the Federated Wiki modules

The Federated Wiki package updates, that don't require a change to the versions specified in `package.json`,
can be achieved by adding an `update` marker, adding it to the repository, and pushing the update to OpenShift.
The presence of the `update` marker is detected by the `build` action hook, and `npm update` is run.

```cmd
  touch .openshift/markers/update
  git add .
  git commit -m "create update marker"
  git push
```


### Pulling in changes to wiki-openshift-quickstart

The upstream repository will be updated when there is a change to either OpenShift, or Federated Wiki that requires the
quickstart to be modified.

To update, you will need to pull in the upstream changes, and merge them. You will also want to review any local
changes, and ensure no additional steps are required.

At its simplest all that is required is, though if you have made any configuration changes, e.g. configured a storetype,
you will want to check these are still in effect before doing the `git push` to update OpenShift:
```cmd
  git fetch upstream
  git merge upstream/master
  git push
```
Though if you have made any local changes, you may need to checkout the master branch, and handle any conflicts
in the merge.


## Configuration

### Storetype

By default flat files will be used store any edits. The alternatives are: -
* LevelDB - modify `package.json` to include `    "wiki-storage-leveldb": "*",` in the dependencies, and
uncomment the line, shown below, in `server.js`

```js
        /*
        self.database = '{"type": "leveldb"}';
        */
```
* MongoDB - to use MongoDB you will need to add the MongoDB cartridge:
```cmd
  rhc add-cartridge --app wiki --cartridge mongodb-2.4
```

modify `package.json` to include the `  "wiki-storage-mongodb": "*",` in the dependencies, and uncomment the lines, shown below, in `server.js`

```js
        /*
        if (process.env.OPENSHIFT_MONGODB_DB_URL) {
          self.connection_string = process.env.OPENSHIFT_MONGODB_DB_USERNAME + ":" + process.env.OPENSHIFT_MONGODB_DB_PASSWORD + "@" + process.env.OPENSHIFT_MONGODB_DB_HOST + ':' + process.env.OPENSHIFT_MONGODB_DB_PORT + '/' + process.env.OPENSHIFT_APP_NAME;
            self.database = '{"type": "mongodb", "url": "' + self.connection_string + '" }';
        }
        */
```

### Farm Mode

To enable Farm Mode you will need to uncomment the lines, shown below, in `server.js`

```js
/*
self.farm = TRUE;
self.farmPort = 20000;
*/
```

**N.B.** To create wikis in the farm you will need to use the OpenShift tools to create aliases.

**N.B.** The MongoDB storetype is thought not to be tested with Farm Mode, and will probably not work.

### Pushing configuration changes to OpenShift

Then push the repo
```cmd
  git add .
  git commit -m "wiki configured"
  git push
```

N.B. The first `git push` will take a while to complete as it also uses npm to install
the wiki package with all its dependencies.

That's it, you can now checkout your application at:
```
  http://wiki-$yournamespace.rhcloud.com
```
One of the first things you will want to do is to claim your site.

## Backing Up Your Data

The directories listed below can be copied using `sftp`. You could alternatively used `snapshots` but these
save the entire application, rather than just the data, so create a bigger archive.

### Flat Files

Your data is stored in `$OPENSHIFT_DATA_DIR/pages` and `$OPENSHIFT_DATA_DIR/status`.

### LevelDB

Your data is stored in `$OPENSHIFT_DATA_DIR/leveldb` and `$OPENSHIFT_DATA_DIR/status`. If you created any
pages before starting to use LevelDB, you will also want to save `$OPENSHIFT_DATA_DIR/pages` as old pages will
only get saved to LevelDB when they are modified.

### MongoDB

Your data can be backed up using the MongoDB tools, specifically `mongodump`. There is some documentation
on OpenShift.

### Farm Mode

Each wiki in a farm will have its data saved in a separate sub-directory `$OPENSHIFT_DATA_DIR/{FQDN}`.
Where `{FQDN}` is the alias used to access the wiki.


## Developer Notes

Further information about the Federated Wiki node package can be found at:

https://github.com/fedwiki/wiki-node

The OpenShift `nodejs` cartridge documentation can be found at:

http://openshift.github.io/documentation/oo_cartridge_guide.html#nodejs
