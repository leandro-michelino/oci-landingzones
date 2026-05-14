import io
import json

from fdk import response


def handler(ctx, data: io.BytesIO = None):
    payload = {}
    if data:
        body = data.getvalue()
        if body:
            try:
                payload = json.loads(body.decode("utf-8"))
            except ValueError:
                payload = {"raw": body.decode("utf-8", errors="replace")}

    name = payload.get("name", "OCI Functions")
    result = {
        "message": f"hello from {name}",
        "function": ctx.FnName(),
        "app": ctx.AppName(),
    }

    return response.Response(
        ctx,
        response_data=json.dumps(result),
        headers={"Content-Type": "application/json"},
    )
