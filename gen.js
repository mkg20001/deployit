'use strict'

const fs = require('fs')
const path = require('path')
const p = (...a) => path.join(__dirname, ...a)
const cp = require('child_process')
const escape = require('shell-escape')
const parse = require('bash-parser')
const read = path => fs.readFileSync(path).toString()

require('colors')

const log = (...args) => {
  let a = [...args]
  console.log(a.shift().bold, ...a)
}

const die = (...args) => {
  log('ERROR', ...args)
  process.exit(1)
}

const args = process.argv.slice(2)

const platform = args.shift()

function ipfsAdd (path) {
  log('IPFS ADD', path)
  if (!fs.existsSync(path)) die(path, 'does not exist')
  const p = cp.spawnSync('ipfs', ['add', '-r', '-Q', path])
  return p.stdout.toString().replace(/[^a-z0-9]/gmi, '')
}

function ipfsAddBuf (buf) {
  const r = '/tmp/IPFS_ADD_' + Math.random()
  fs.writeFileSync(r, buf)
  const h = ipfsAdd(r)
  fs.unlinkSync(r)
  return h
}

function ipfsDL (hash) {
  return 'https://ipfs.io/ipfs/' + hash
}

const tree = {}

function scriptProcess (path, ctx) {
  let e
  log('SCRIPT', path)
  const con = read(path)
  if (tree[path]) {
    e = tree[path]
  } else {
    e = tree[path] = con.split('\n').filter(l => !!l.trim() || ctx.debug).map(l => {
      const getArgs = () => parse(l).commands[0].suffix.map(v => v.text)
      switch (l.trim().split(' ').shift()) {
        case 'include':
          return {
            include: getArgs()
          }
        case 'cpf':
          const a = getArgs()
          const hash = ipfsAdd(p(a[0]))
          return ctx.type == 'sh' ? ((ctx.platform == 'linux' ? escape(['wget', '-qO-', ipfsDL(hash)]) : escape(['curl', '--silent', ipfsDL(hash)])) + ' > ' + a[1]) : (escape(['Download-File', ipfsDL(hash)]) + ' ' + a[1])
          break
        default:
          return l
      }
    })
  }
  e = e.filter(l => typeof l === 'string' && l.startsWith('#!/bin') ? false : true).map(l => {
    if (typeof l === 'string') return l
    if (l.include) {
      let pa = p(...l.include)
      if (!fs.existsSync(pa) && fs.existsSync(pa + '.' + ctx.type)) pa += '.' + ctx.type
      else if (!fs.existsSync(pa)) die('Script file', pa, 'missing')
      let nctx = script(pa, true)
      nctx.isMain = false
      return scriptProcess(pa, nctx)
    }
  })
  if (ctx.debug) {
    e.unshift('#BEGIN ' + path)
    e.push('#END ' + path)
  }

  if (ctx.isMain) {
    if (ctx.type == 'sh') {
      e.unshift('#!/bin/bash', 'export PLATFORM=' + escape([platform]))
    }
  }
  return e.join('\n')
}

function script (pth, ctxOnly) {
  let ctx = {
    isMain: true,
    platform,
    type: path.extname(pth).split('.').pop(),
    isDebug: !!process.env.DEBUG,
    debug: !!process.env.DEBUG
  }
  if (ctxOnly) return ctx
  return scriptProcess(pth, ctx)
}

function doWin () {
  const main = script(p('main/main_win.sh'))
  const mainh = ipfsAddBuf(main)
  const pre_main = script(p('pre/pre_win.ps1')).replace('SCRIPTSC', ipfsDL(mainh))
  const pre_mainh = ipfsAddBuf(pre_main)
  const pre = read(p('pre/preamble_win.ps1'))
  const presc = pre.replace('DOWNLOAD', ipfsDL(pre_mainh))

  if (process.env.PRINT_DEBUG) {
    console.log('---SCRIPT---')
    console.log(presc)
    console.log('---PRE---')
    console.log(pre_main)
    console.log('---MAIN---')
    console.log(main)
  } else if (process.env.QUIET_OUT) {
    console.error(presc)
  } else {
    console.log('Run this in an admin powershell to start deployment:')
    console.log(presc)
  }
}

function doLinux () {
  const main = script(p('main/main_linux.sh'))
  const mainh = ipfsAddBuf(main)
  const pre = read(p('pre/preamble_linux.sh'))
  const presc = pre.replace('DOWNLOAD', ipfsDL(mainh))

  if (process.env.PRINT_DEBUG) {
    console.log('---SCRIPT---')
    console.log(presc)
    console.log('---MAIN---')
    console.log(main)
  } else if (process.env.QUIET_OUT) {
    console.error(presc)
  } else {
    console.log('Run this in a shell to start deployment:')
    console.log(presc)
  }
}

function doWinDeploy () {
  // Problem: During deployment most installs don't work until the desktop is ready.
  // Solution: Scheudle them to run _after_ the desktop has been setup (start powershell as bg window, sleep, continue, finish)
  const main = script(p('main/main_win.sh'))
  const mainh = ipfsAddBuf(main)
  const pre_main = script(p('pre/pre_win.ps1')).replace('SCRIPTSC', ipfsDL(mainh))
  const pre_mainh = ipfsAddBuf(pre_main)
  const pre_timed = script(p('pre/pre_timed.ps1')).replace('SCRIPTSC', ipfsDL(pre_mainh))
  const pre_timedh = ipfsAddBuf(pre_timed)
  const pre = read(p('pre/preamble_win.ps1'))
  const presc = pre.replace('DOWNLOAD', ipfsDL(pre_timedh))

  const postCMD = 'start powershell -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "' + presc.replace(/\n/g, '') + '"'

  // Next: Run VBoxManage to prepare vm
  const args = process.env.WIN10 ? [
    'unattended', 'install',
    '--iso=/home/maciej/IMG/Win10_1709_German_x64.iso',
    '--user=maciej',
    '--password=helloworld',
    '--full-user-name=Maciej Krüger',
    '--install-additions',
    '--locale=de_DE',
    '--country=DE',
    '--time-zone=Europe/Berlin',
    '--hostname=win10-devvm.mkg20001.io',
    '--post-install-command=' + postCMD,
    'DevVM10'
  ] : [
    'unattended', 'install',
    '--iso=/home/maciej/IMG/Win7_HomePrem_SP1_German_x64.iso',
    '--user=maciej',
    '--password=helloworld',
    '--full-user-name=Maciej Krüger',
    '--install-additions',
    '--locale=de_DE',
    '--country=DE',
    '--time-zone=Europe/Berlin',
    '--hostname=win7-devvm.mkg20001.io',
    '--post-install-command=' + postCMD,
    'DevVM2'
  ]

  if (process.env.DO_RUN) cp.spawn('VBoxManage', args, {stdio: 'inherit'}).on('exit', process.exit)
  else console.log('VBoxManage ' + args.map(JSON.stringify).join(' '))
}

function main () {
  switch (platform) {
    case 'win':
      log('DO', 'win')
      doWin()
      break
    case 'linux':
      log('DO', 'linux')
      doLinux()
      break
    case 'windeploy':
      log('DO', 'win (deploy)')
      doWinDeploy()
      break
    default:
      log('ERROR', 'no platform specified')
  }
}

main()
