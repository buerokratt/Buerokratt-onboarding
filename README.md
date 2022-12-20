## Bürokratt onboarding

### In case you are just wondering

Bürokratt is an initiative by the [Ministry of Economics Affairs and Communications of Estonia](https://www.mkm.ee/) to, in the end, provide all of the Estonian government e-services (about 3,000 of them), plus potentially any of the private sector ones, via both text-based and voice input.

Technical implementation of Bürokratt is provided by the Department of Machine Learning and Language Technology of [Information System Authority of Estonia](https://www.ria.ee/).

### If you want to participate as a developer

The first thing to understand is that we strongly believe in **DSL-based developments**. This means that unless you are working with either language technology or developing our core components themselves, you almost never get to write code in Java or other so-called actual programming languages. Instead, you work with YAML, standard SQL queries as text files, [Handlebars DSL](https://handlebarsjs.com/), etc. To better understand the logic behind it, please [read this article](https://medium.com/digiriik/reasons-behind-b%C3%BCrokratt-giving-less-freedom-to-developers-fc04b0751).

First of all, take a look at our GitHub project at [https://github.com/buerokratt](https://github.com/buerokratt).

**Key repos to take a look at** are (in that order)

#### https://github.com/buerokratt/Ruuter

All of our services are based on Ruuter. Whenever you want to make POST, GET or other requests, it's via Ruuter. The same goes for if/else statements, creating and using templated services, etc. Go through [Ruuter's guide](https://github.com/buerokratt/Ruuter/blob/main/samples/GUIDE.md) and definitely create your own [Ruuter-based mock services](https://github.com/buerokratt/Ruuter/blob/main/samples/steps/mock.md) to get the first grip of Ruuter.

Reverse proxy

1. https://github.com/buerokratt/Resql
   
2. [https://handlebarsjs.com/](https://handlebarsjs.com/)
   
3. [https://github.com/buerokratt/TIM](https://github.com/buerokratt/TIM)

### If you want to participate as a language technologist

### If you want to start using Bürokratt as an institution

### If you're asked to deploy Bürokratt for your client

### Warranty and responsibilities
