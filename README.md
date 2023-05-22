# Walkaround

## Dev setup

- `mix deps.get`
- `mix ecto.create`
- `mix ecto.migrate`
- `mix phx.server`

## Deployment

Deploy with `fly deploy`. Migrations run automatically.

Live URL: https://walkaround-prod.fly.dev/

Some code rules apply because this app is deployed using `mix release`:

- Only reference Unix env vars in runtime.exs, not config.exs.
- Use Walkaround.Helpers.env() instead of Mix.env().


## AWS S3 setup

I flail around with this every damn time. So for the record, here's the steps I took to set up Arc with S3:

- I started setting up Cloudflare R2, then realized that there's no way to create an API token with access only to a single bucket (!?), so switched back to S3.
- See git commit 41aae26 for the code changes & Arc config. It mostly follows the [Arc setup guide](https://github.com/stavro/arc#configuration) except I make the hostname explicit (s3.us-east-1.amazonaws.com).
- Create an S3 bucket, with public access enabled (ie not blocked).
- Create an IAM user with a custom permissions policy granting it read/write access to this bucket:

```
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": [
				"s3:GetObject",
				"s3:PutObject",
				"s3:PutObjectAcl",
				"s3:ListBucket",
				"s3:DeleteObject"
			],
			"Resource": [
				"arn:aws:s3:::topherhunt-walkaround",
				"arn:aws:s3:::topherhunt-walkaround/*"
			]
		}
	]
}
```

- Use that IAM user's access key as the Arc credentials.
