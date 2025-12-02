import { getCookie, setCookie, removeCookie } from '../CookieUtil'

describe('CookieUtil', () => {
    beforeEach(() => {
        // Clear all cookies before each test
        document.cookie.split(';').forEach((cookie) => {
            const name = cookie.split('=')[0].trim()
            document.cookie = `${name}=; path=/; max-age=0`
        })
    })

    describe('setCookie and getCookie', () => {
        it('should set and retrieve a cookie', () => {
            setCookie('testKey', 'testValue')
            const result = getCookie('testKey')
            expect(result).toBe('testValue')
        })

        it('should return undefined for non-existent cookie', () => {
            const result = getCookie('nonExistentKey')
            expect(result).toBeUndefined()
        })
    })

    describe('removeCookie', () => {
        it('should remove an existing cookie', () => {
            setCookie('testKey', 'testValue')
            expect(getCookie('testKey')).toBe('testValue')

            removeCookie('testKey')
            expect(getCookie('testKey')).toBeUndefined()
        })
    })
})
