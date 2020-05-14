### Unreleased

### 0.2.0 - 2020-05-14

**Breaking changes**

- Use named `ThreadItem` and `Error` instead of generic object & error [#25](https://github.com/GetSilverfin/cubscout/pull/25)
- On association method calls, do not make a request to Helpscout by default [#24](https://github.com/GetSilverfin/cubscout/pull/24)
- `Cubscout::Scopes.all` method returns a `Cubscout::List` object instead of an array of items [#23](https://github.com/GetSilverfin/cubscout/pull/23)

**Dependencies**

- Bump rack from 2.0.7 to 2.0.8 [#21](https://github.com/GetSilverfin/cubscout/pull/21)
- Update rake requirement from ~> 10.0 to ~> 13.0 [#22](https://github.com/GetSilverfin/cubscout/pull/22)

### 0.1.1 - 2019-11-14

**Fixes**

- use new Auth endpoint after deprecation of old one by helpscout [#16](https://github.com/GetSilverfin/cubscout/issues/16)

### 0.1.0 - 2019-03-21

BROKEN: DO NOT USE (Auth endpoint deprecated by Helpscout)
