# Website Redirect

Redirect all pages with all parameters from one hostname to another.

This module helps to keep bookmarks and links intact when you move a service between subdomains.

It will let you redirect `foo.bar.example.com/whatever/goes/here.html` to `floo.blar.example.net/whatever/goes/here.html` and every page under the domain without having to run a server or enumerate pages or path rules.

### Usage

```hcl
module "foo_bar_example_com" {
  source = "github.com/007/terraform-domain-redirect"

  certificate_arn    = data.aws_acm_certificate.arn
  source_domain      = "foo.bar.example.com"
  destination_domain = "floo.blar.example.net"
}
```
