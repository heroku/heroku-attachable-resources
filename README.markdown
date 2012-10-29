# Heroku attachable resources

Adds attachable resources functionality to CLI.

## Installation

```bash
$ heroku plugins:install git@github.com:heroku/heroku-attachable-resources.git
````

Once you've got the plugin installed, you can use it to share some resources
among several apps.

## Example: Share a Database

You can share a [Heroku Postgres][] database by attaching it to another app.

First, get its name:

```
$ heroku addons -a myapp
=== sighing-sagely-1469
Billing App: myapp
Config:      DATABASE_URL
Type:        heroku-postgresql:ronin
```

The name for this database is `sighing-sagely-1469`.
Now you can attach it to another app:

```
$ heroku addons:add -a myapp2 sighing-sagely-1469
Adding sighing-sagely-1469 to myapp2... done
sighing-sagely-1469 assigned to DATABASE_URL.
Use `heroku addons:docs heroku-postgresql:ronin` to view documentation.
```

## Usage

For usage see:

```bash
$ heroku help addons
```


[Heroku Postgres]: https://addons.heroku.com/heroku-postgresql