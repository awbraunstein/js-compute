# js-compute

A distributed JavaScript cloud-computing platform

## js-compute is just a script tag

Create a task and put the script tag on your site to have visitors
compute. Computations are all done via webworkers on a separate
thread. 

## Getting Started

### Install the necessary node modules

Install redis - `brew install redis`

Install npm and node

Install node modules - `npm install .`

### Set the host

In src/app.coffee, change the HOST variable to where the server's
address. for example, `HOST = 'http://js-compute.yourhost.com:'`

### Run the server

`coffee -w ./src`

## Redis

The redis schema is as follows:

- 'task:$id:code' -- the code to be run for task $id
- 'task:$id:inputs' -- queue of inputs for task $id. These inputs are all potentially unrun
- 'task:$id:results' -- hash mapping inputs (JSON strings as produced by JSON.stringify) to results (JSON strings as produced by JSON.stringify)
- 'task:all' -- set of all task ids
 
