Barrage
=======

<OUT OF DATE>

Scalable http load testing framework

# Another http load testing system?  WTF

I agree with you but let me state my case.  Having used systems like Siege and Apache Bench I wanted something that gives me the following things:

1. Easy to model user interaction with my system
2. Something that can scale out so I can just hammer the living crap out of my server

While mulitple systems offered some of these, none of them had it to the level that I wanted.  So that is when I came up with Barrage.  

Having a background in game development I really love behavior trees.  They are simple to model and the best thing is when you do them right you don't need to be an engineer to create them.  And when looking at all these different load testing systems I thought to myself "Man, I really wish I could just create a behavior tree to model all this crap out fast and then run it".  So that is how the idea was born.

# Basic config

Barrage is written in Erlang so the markup is currently erlang config based but I will add support for JSON soon.

## Actions

First you need to define a bunch of actions.  This is what the system will do as they execute.  A action can basically be thought of as two parts:

1. The http end point you want to hit
2. The data you are sending or recieving and what you want to do with it.

### Example Action

```erlang

%%=====================================================
%% Action: Login
%% Used to simulate a user logging into the system
%%=====================================================
{[
    {name, <<"login">>},
    {url, "http://127.0.0.1:1337/login"},
    {type, get},
    {args_type, http},
    {args, [
        {"username", "foo"},
        {"password", "bar"}
    ]},
    {results,[ 
        {"session", "$SESSION"}
    ]},
    {results_type, json}
]}.
```
I will break these down for ya:

1. name = The name of this action.  When you build behaviors this is the text you will refer to it later as
2. url = The full URL of the endpoint you want to hit.  NOTE:  I am working on making this a variable you can set and replace
3. type = The http type of request to send.  Currently support get, post, put
4. args_type = how should the arguments be packaged.  Currently I only support http but JSON will be supported soon
5. args = Array of key/value pairs for the http arguments
6. results = currently it is expected that all data will come back as json (big assumption I know and will change later).  Each "client" process will have a key/value cache assigned to it so this will look for a memember called "session" in the returning object and save it as a token called "$SESSION.  In your scripts you can ask the client for this value back by using the key $SESSION.  NOTE:  This is not very clear.  I need o doc this better with a better example.
7. results_type = How should the results be process.  Currently I only support json

### System Actions

These are here to help you build more complex behaviors.  Currently I support the following system actions:

1. <<"ordered">> = This action will execute all it's children in order they are defined in the array
2. <<"random">> = This action will randomly pick one child to execute
3. <<"wait">> = This action will sleep the client for N amount of time
4. <<"random_wait">> = This action will sleep the client for a random amount of time defined a 0-N milliseconds

## Behaviors

This is where the fun comes.  You can build out a really complex set of client interactions by defining a "behavior" to execute.

### Example Behavior

```erlang
%%=====================================================
%% Behavior: Simple User 
%% Model a super simple user session
%%=====================================================
{[
    {name, <<"Simple User">>},
    {tree, [
        { action, <<"ordered">>},
        { children, [
            [
                %% Prepare the system.
                %% I want to create 1000 random cards
                { action, <<"ordered">>},
                { args, [
                    {count, 1000},  %% <-- This says run through all the children nodes 1000 times
                    {report, false} %% <-- Add this action to the report generated by the load test.  Default is true 
                ]},
                { children, [
                    [
                        { action, <<"create random card">> } %% <-- Adds a random card to the database
                    ]
                ]}
            ],
            [{ action, <<"login">>}], %% <-- Log into the system
            [{ action, <<"random">> }, %% <-- Randomly select a child node to execute
                { args, [{count, 10}]} %% <-- Do this random selection 10 times
                { children, [
                    [{ action, <<"wait">>}, {args, [{time, 1000}]}], %% <-- Make this child wait 1 second
                    [{ action, <<"random_wait">>}, {args, [{time, 2000}]}], %% <-- Make this child wait 0 - 2 seconds
                    [{action, <<"random">>},      %% <-- Randomly select one of the following actions
                        { children, [
                            [{ action, <<"add_card">>}],
                            [{ action, <<"get_cards">>}]
                        ]},
                        {args, [{min_time, 5000}]} %% <-- Keep doing this random select for up to 5 seconds
                    ],
                    [{ action, <<"get_cards">>}]
                ]},
            ]
        ]}
    ]}
]}.
```
So you maybe saying to yourself "WTF, I though you side this crap was meant to be easy?!?!".  There is one major feature you are missing:

This is a data file, not code.  After the base system has stabilize and works well the plan is to start working on a slick UI front end like so:

[Example Behavior Tree Editor](http://brainiac.codeplex.com/)


I was thinking about putting something in HTML5 so I can get the same kind of user interaction but it can also be used to display reports and test runs from the server.

# Did I sell ya on it?

If not I understand. I am not trying to convince people who get a lot of mileage out of existing systems to believe this is somehow better for your use cases.

If this does sound cool then please stay tuned.  Barrage is still in the prototype/weekend work phase so don't expect a lot soon...
