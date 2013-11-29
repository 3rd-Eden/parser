'use strict';

var debug = require('debug')('ircb:orchestra')
  , Leverage = require('leverage')
  , crypto = require('crypto')
  , redis = require('redis')
  , path = require('path')
  , fs = require('fs');

//
// Nope!
//
function nope() { /* noop */ }

/**
 * IRC protocol parser.
 *
 * cfg:
 * - host: redis host
 * - port: redis port
 * - auth: redis auth
 *
 * @constructor
 * @param {Object} cfg Configuration
 * @api public
 */
function Parser(cfg) {
  this.cfg = cfg || {};

  //
  // Initialise our Pub/Sub connection.
  //
  Leverage.call(this, this.redis(), this.redis());
  this.lualoader();
}

Parser.prototype.__proto__ = Leverage.prototype;

/**
 * Fill the database with Lua IRC parser information.
 *
 * @api private
 */
Parser.prototype.lualoader = function lualoader() {
  var directory = __dirname +'/lua'
    , multi = this._.client.multi();

  fs.readdirSync(__dirname +'/lua').forEach(function each(script) {
    if ('.lua' !== path.extname(script)) return;

    var location = path.join(directory, script)
      , code = fs.readFileSync(location, 'utf-8');

    multi.set('lua::parser.'+ script,
      crypto.createHash('sha1').update(code).digest('hex').toString()
    );
  });

  multi.exec(function (err) {
    if (err) return debug('failed to load parsers in to redis');

    debug('added all parsers in to redis');
  });
};

/**
 * Create a new Redis connection.
 *
 * @returns {Redis}
 * @api private
 */
Parser.prototype.redis = function createRedis() {
  var red = redis.createClient(this.cfg.port, this.cfg.host);

  red.on('error', function error(err) {
    debug('redis client received an error %s', err.message);
  });

  if (this.cfg.auth) red.auth(this.cfg.auth);

  return red;
};

//
// Expose the module
//
module.exports = Parser;
