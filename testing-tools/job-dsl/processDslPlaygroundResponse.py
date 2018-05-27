import sys, json

response = json.load(sys.stdin)
stacktrace = response['stacktrace']

if stacktrace:
    raise Exception('Error while processing DSL script: %(stacktrace)s.' % locals())

for result in response['results']:
    print('<!--')
    print(result['name'])
    print('-->')
    print(result['xml'])
