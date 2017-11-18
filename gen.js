"use strict"

const fs = require("fs")
const path = require("path")
const p = (...a) => path.join(__dirname, ...a)
const cp = require("child_process")
const escape = require('shell-escape')
const parse = require('bash-parser')
const read = path => fs.readFileSync(path).toString()

require("colors")

const log = (...args) => {
  let a = [...args]
  console.log(a.shift().bold, ...a)
}

const die = (...args) => {
  log("ERROR", ...args)
  process.exit(2)
}

const args = process.argv.slice(2)

const platform = args.shift()

function ipfsAdd(path) {
  log("IPFS ADD", path)
  if (!fs.existsSync(path)) die(path, "does not exist")
  const p = cp.spawnSync("ipfs", ["add", "-r", "-Q", path])
  return p.stdout.toString().replace(/[^a-z0-9]/gmi, "")
}

function ipfsAddBuf(buf) {
  const r = "/tmp/IPFS_ADD_" + Math.random()
  fs.writeFileSync(r, buf)
  const h = ipfsAdd(r)
  fs.unlinkSync(r)
  return h
}

function ipfsDL(hash) {
  return "https://ipfs.io/ipfs/" + hash
}

const tree = {}

function scriptProcess(path, ctx) {
  let e
  log("SCRIPT", path)
  const con = read(path)
  if (tree[path]) {
    e = tree[path]
  } else {
    e = tree[path] = con.split("\n").filter(l => !!l.trim()).map(l => {
      const getArgs = () => parse(l).commands[0].suffix.map(v => v.text)
      switch (l.trim().split(" ").shift()) {
      case "include":
        return {
          include: getArgs()
        }
      case "cpf":
        const a = getArgs()
        const hash = ipfsAdd(p(a[0]))
        return ctx.type == "sh" ? (escape(["curl", "--silent", ipfsDL(hash)]) + " > " + escape(a[1])) : escape(["Download-File", ipfsDL(hash), a[1]])
        break;
      default:
        return l
      }
    })
  }
  e = e.filter(l => typeof l == "string" && l.startsWith("#!/bin") ? false : true).map(l => {
    if (typeof l == "string") return l
    if (l.include) {
      let pa = p(...l.include)
      if (!fs.existsSync(pa) && fs.existsSync(pa + "." + ctx.type)) pa += "." + ctx.type
      else if (!fs.existsSync(pa)) die("Script file", pa, "missing")
      let nctx = script(pa, true)
      nctx.isMain = false
      return scriptProcess(pa, nctx)
    }
  })
  if (ctx.isMain) {
    if (ctx.type == "sh") {
      e.unshift("#!/bin/bash", "export PLATFORM=" + escape([platform]))
    }
  }
  return e.join("\n")
}

function script(pth, ctxOnly) {
  let ctx = {
    isMain: true,
    platform,
    type: path.extname(pth).split(".").pop()
  }
  if (ctxOnly) return ctx
  return scriptProcess(pth, ctx)
}

function doWin() {
  const main = script(p("main/main_win.sh"))
  const mainh = ipfsAddBuf(main)
  const pre_main = script(p("pre/pre_win.ps1")).replace("SCRIPTSC", ipfsDL(mainh))
  const pre_mainh = ipfsAddBuf(pre_main)
  const pre = read(p("pre/preamble_win.ps1"))
  const presc = pre.replace("DOWNLOAD", ipfsDL(pre_mainh))
  
  console.log("---SCRIPT---")
  console.log(presc)
  console.log("---PRE---")
  console.log(pre_main)
  console.log("---MAIN---")
  console.log(main)
}

function doLinux() {
  const main = script(p("main/main_linux.sh"))
  const mainh = ipfsAddBuf(main)
  const pre = read(p("pre/preamble_linux.sh"))
  const presc = pre.replace("DOWNLOAD", ipfsDL(mainh))

  console.log("---SCRIPT---")
  console.log(presc)
  console.log("---MAIN---")
  console.log(main)
}

function main() {
  switch (platform) {
  case "win":
    log("DO", "win")
    doWin()
    break;
  case "linux":
    log("DO", "linux")
    doLinux()
    break;
  default:
    log("ERROR", "no platform specified")
  }
}

main()
