---
title: Nix - From Zero to Docker + Haskell
author: Ben Kolera
patat:
    wrap: true
    columns: 80
    incrementalLists: true
---

```
              _   _ _         ___     _   _           _        _ _ 
             | \ | (_)_  __  ( _ )   | | | | __ _ ___| | _____| | |         
             |  \| | \ \/ /  / _ \/\ | |_| |/ _` / __| |/ / _ \ | |         
             | |\  | |>  <  | (_>  < |  _  | (_| \__ \   <  __/ | |         
             |_| \_|_/_/\_\  \___/\/ |_| |_|\__,_|___/_|\_\___|_|_|         
           The fundamentals & war stories from dev through to docker!
```

---

# Ephox's First Haskell Service!

- Recently, Ephox deployed their first Haskell service, with Nix!

- It was difficult going and we were sad and confused at times.

- But we feel like it was worth it in the end!

---

# Why Nix?

- We love infrastructure as code

- Especially if that infra can work from dev through to production

- We love immutable, reproducable, reliable things

- We love functional things (see point three)

---

# Talk Goals

- This talk shares the fundamentals that we learned along the way.

- And hopefully makes it easier for those that come afterwards!

---

# Parts of the Puzzle

- Nix: Language, small set of built in functions, manages the nix store.

- Nixpkgs: Nix code that both helps people package their code and has premade
  derivations for open source code (e.g - for each hackage package).
  
- NixOS: A layer of nix expressions on top of NixOS for setting up a full OS.

- Hydra: A CI server powered by Nix.

- NixOps: A deployment tool powered by Nix.

---

# You don't need to run NixOS

- Nix & Nixpkgs will build on non NixOS machines. 

- There are rough edges though (on both Mac and non NixOS Linux).

- If you like nix, you'll end up on NixOS soon enough. :)

---

# What we'll cover

- Nix: The language and the fundamentals

- Nixpkgs: Specifically the docker and haskell parts

- NixOS: Take a tiny peek at the config running this host. 

# What we won't cover

- NixOps: We are still using ansible to spin up AWS.

- Hydra: We are building the images on nixos jenkins nodes.

---

```
                                  _   _ _                                   
                                 | \ | (_)_  __
                                 |  \| | \ \/ /
                                 | |\  | |>  <
                                 |_| \_|_/_/\_\
```

---

# Nix is:

- A programming language with a very small set of primitives and functions.

- A package manager

---

# Whose core job is to:

- create and compose derivations (build actions)

- build the artifacts from said derivations/actions. 

- to manage sources, derivations and built artifacts in the nix store.

---

```
               ____            _            _   _                          
              |  _ \  ___ _ __(_)_   ____ _| |_(_) ___  _ __  ___ 
              | | | |/ _ \ '__| \ \ / / _` | __| |/ _ \| '_ \/ __|
              | |_| |  __/ |  | |\ V / (_| | |_| | (_) | | | \__ \
              |____/ \___|_|  |_| \_/ \__,_|\__|_|\___/|_| |_|___/
```


- The fundamental building block of nix is called a derivation.

- Which is a set of instructions for building an artifact (source, compiler,
  linking, etc) 

- We make a derivation in nix with the `derivation` built in.

---

# Jump into Code

Lets checkout ./default.nix and ./builder.sh !

---

# Lets see the derivation now

- And build with `nix-instantiate` to make and look at the derivation.

- Nothing has been built so far. We have these two files in the store:

    - /nix/store/63w38wq899z17d3pkkccsb4lxm2gida0-00-helloworld.drv

    - /nix/store/8hh8dafyfg3y5j9aw46fkz893cp8im45-builder.sh

---

# And then nix-build to build the derivation for our system

  - /nix/store/kfl2iav6rrryxy224if57r4hx2xbl4jw-00-helloworld

---

# Derivations are

- All the build inputs:
    - Source
    - Libraries
    - Compilers
    - Tools for testing
    - Etc
    
- And a script(s) to build the code on a target system.

- Which result in a "binary" cache output(s) of the built stuff. 

---

# Implications of this

- Nix is a source based package manager. 

- But built artifacts can be cached and shared between machines. 

- This is safe because of the focus on reproducability.

- If no cached built artifacts, can always build from source.

---

# Warning!

- The artifacts built by a derivation must be pure (same inputs must return the
  same outputs on the filesystem).

- Looking into the store can be surprising sometimes. file mtimes and other
  timestamps in files are set to epoch + 1 second to ensure purity.

---

```
                        ____              _                               
                       / ___| _   _ _ __ | |_ __ ___  __
                       \___ \| | | | '_ \| __/ _` \ \/ /
                        ___) | |_| | | | | || (_| |>  < 
                       |____/ \__, |_| |_|\__\__,_/_/\_\
                              |___/                     
```

---

# Primitives

- Strings

- Paths

- Integers

- Boolean

- `null`

---

# Structures 

- Lists: 
    - `["there" "are" "no" "commas"]`
    - `["there" "are"] ++ ["no" "commas"]`

- Sets: 
    - `{ name = "foo"; version = "1.0.0"; }`
    - `{ name = "foo"; } // { version = "1.0.0"; }`

- Let : `let foo = "bar"; in foo`

---

# Conditionals

- Conditional : `if foo then "bar" else "baz"`

- Assert: `assert shouldHaveThingo -> thingo != null;`

---

# Functions

- `let id = x: x`

- `let const = a: b: a`

- `{ message ? "world" }: "Hello ${message}"`


---

```
                _____                 _   _                   _           
               |  ___|   _ _ __   ___| |_(_) ___  _ __   __ _| |
               | |_ | | | | '_ \ / __| __| |/ _ \| '_ \ / _` | |
               |  _|| |_| | | | | (__| |_| | (_) | | | | (_| | |
               |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|\__,_|_|
                                                                
               ____            _            _   _                 
              |  _ \  ___ _ __(_)_   ____ _| |_(_) ___  _ __  ___ 
              | | | |/ _ \ '__| \ \ / / _` | __| |/ _ \| '_ \/ __|
              | |_| |  __/ |  | |\ V / (_| | |_| | (_) | | | \__ \
              |____/ \___|_|  |_| \_/ \__,_|\__|_|\___/|_| |_|___/
```

---

# Derivations take inputs

- Whether they be other derivations (source/dependencies/etc)

- Or pure nix values (configuration)

- Nix's guarantee is that for the same inputs, the same output will be produced.

- Nix gives us the ability to write functions that set our code up as the user wants!

- This means we get away from the divide between config and package management.

---

# Check out some code!

- See [./00-nix/01-functional_derivations/default.nix]

- Note that when we build it we get two derivations and artifacts. 

- Changing the strings and rebuilding gives new store paths. 


---

```
                        _   _ _            _                              
                       | \ | (_)_  ___ __ | | ____ _ ___ 
                       |  \| | \ \/ / '_ \| |/ / _` / __|
                       | |\  | |>  <| |_) |   < (_| \__ \
                       |_| \_|_/_/\_\ .__/|_|\_\__, |___/
                                    |_|        |___/     
```

- To build bigger and better things, we really need to start using the extra
  goodies from nixpkgs.
  
- This brings in loads more helper functions and a huge set of premade
  derivations for OSS.

---

# Check out some code!


- See [./01-nixpkgs/00-stdenv/dynamodb-local.nix]

- See [./01-nixpkgs/00-stdenv/default.nix]

- Build it!

- Install the build derivation & run it.

---

# Check out the work that nix is doing!

- Runtime deps: `nix-store -q --tree $(which dynamodb-local)`

- Build deps: `nix-store -q --tree $(nix-store -qd $(which dynamodb-local))`

- This looks complicated, and it is, but it is all so we can install a newer JRE
  later for other code and not break dynamoDB.

---
 
# Copying all of that goodness TODO
 
- I have previously set up a public key on this machine as per these instructions:
  https://blog.joel.mx/posts/how-to-use-nix-copy-closure-step-by-step

- Make sure there is no dynamodb on the copy host

- `nix-copy-closure --to talk@192.168.0.14 --sign $(nix-store -q --deriver <dynamodb path>)`

- On the copy: `nix-env -i <derivation_path>`

---

# But where is nixpkgs coming from?!? TODO

- Explain channels

---

# It's possible to make channels out of your services TODO

- Can layer with other nixpkgs 

- Hydra essentially does this, but I haven't got that working yet

---

# Pinning Nixpkgs TODO

- TODO

---

```
                          _   _           _        _ _               
                         | | | | __ _ ___| | _____| | |
                         | |_| |/ _` / __| |/ / _ \ | |
                         |  _  | (_| \__ \   <  __/ | |
                         |_| |_|\__,_|___/_|\_\___|_|_|
                                                       

```

---

# Explain the extent of the haskell environment TODO

- All the GHC versions, GHCJS, curated package snapshot.

---

# Cabal2Nix TODO

- Show how to run cabal2nix to get our package.nix

- And a build.nix

---

# Configuration as derivation input! TODO

- Make our derivation a function and take in config variables to configure it.

- Write out config and wire it into service.

---

# Shell.nix to override things with dev tools TODO

- TODO

- We got into this to stop using docker to setup test dbs and what not for testing.

---

# Problem with Artifact size TODO

- Try copy closuring. See how huge it is. 

- Show tree to show all the cruft.

- Show release.nix that just builds a static artifact for our service.

---

```
                         ____             _                             
                        |  _ \  ___   ___| | _____ _ __ 
                        | | | |/ _ \ / __| |/ / _ \ '__|
                        | |_| | (_) | (__|   <  __/ |   
                        |____/ \___/ \___|_|\_\___|_|   

```

---

# Show how easy it is to ship our derivation into an image TODO

- Be sure to wire in cacerts and alpine base image

---

# Load docker image up and start it TODO

- TODO

---

# Doesn't fulfill the role of docker-compose / etc, though. TODO

- NixOps may do this alright, but I don't know yet. 

---

# Docker is not necessary unless you have existing docker infra TODO

- 


```
                            _   _ _       ___  ____                    
                           | \ | (_)_  __/ _ \/ ___| 
                           |  \| | \ \/ / | | \___ \ 
                           | |\  | |>  <| |_| |___) |
                           |_| \_|_/_/\_\\___/|____/ 
```

---

# Show config used to bring up this VM to show off where this stuff goes. TODO

# Everything in your NixOS config is immutable. Even boot entries! TODO

---

```
                ____                                                    
               / ___| _   _ _ __ ___  _ __ ___   __ _ _ __ _   _ 
               \___ \| | | | '_ ` _ \| '_ ` _ \ / _` | '__| | | |
                ___) | |_| | | | | | | | | | | | (_| | |  | |_| |
               |____/ \__,_|_| |_| |_|_| |_| |_|\__,_|_|   \__, |
                                                           |___/ 
```

---

# Nix is a language and package manager to get immutable, reproducable builds TODO

- This means that we don't have to worry about an update breaking something else
  or worry that we need two versions or configurations of postgres around. 

- This makes rolling back super easy. If we haven't garbage-collected, all of
  the old code and config is still there. 

- This means we can ship built artifacts / caches around easily and safely.

- So easily, in fact, that shipping a docker image with your tried and proven
  nix setup is very easy.
  
- All with a package format that is flexible enough to build a dev environment
  with nix-shell, too.

---

# I don't know about you, but...

- It is lovely to have something safely composable that abstracts over config
  management and package management.

- That is suited from dev environments, to kick ass CI all the way through to prod.

---

```
                      _____ _            _____           _ 
                     |_   _| |__   ___  | ____|_ __   __| |              
                       | | | '_ \ / _ \ |  _| | '_ \ / _` |
                       | | | | | |  __/ | |___| | | | (_| |
                       |_| |_| |_|\___| |_____|_| |_|\__,_|
```

# Acknowledgements

- The NixOS folks for their rad work!

- David Laing & Brian McKenna for fielding all my dumb questions. :)

- Dylan Just for blazing the trail with me at Ephox.

- This awesome site: http://www.bagill.com/ascii-sig.php

- Patat : https://github.com/jaspervdj/patat
