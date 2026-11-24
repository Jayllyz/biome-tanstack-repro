# Biome reopens node_modules type files multiple times

Minimal TanStack Start + Base UI app. During a single `biome lint` run, Biome's scanner opens the same `node_modules/**/*.d.ts` file many times. Every duplicate open has the reason `Index(InitialScan)`.

## Steps

```bash
pnpm install
./repro.sh
```

`repro.sh` runs the tracing command from https://biomejs.dev/guides/investigate-slowness/:

```bash
biome lint --log-level=tracing --log-kind=json --log-file=tracing.json .
```

It then counts the `open_file_internal` spans for each path.

## Expected

The scanner opens each dependency type file once.

## Actual

Sample run: 917 opens of 521 unique files. Per-file counts vary between runs, from 9 to 13 for `route.d.ts`.

```
   9 @tanstack+router-core@1.171.39/.../router-core/dist/esm/route.d.ts
   7 @tanstack+router-core@1.171.39/.../router-core/dist/esm/redirect.d.ts
   7 @tanstack+router-core@1.171.39/.../router-core/dist/esm/Matches.d.ts
   7 @tanstack+router-core@1.171.39/.../router-core/dist/esm/index.d.ts
   6 postcss@8.5.33/node_modules/postcss/lib/result.d.ts
```

## Environment

- @biomejs/biome 2.6.9 (2.2.0 and 2.1.4 also tested, see below), with `linter.domains.project: "all"`
- @tanstack/react-start 1.169.7, @base-ui/react 1.9.0
- pnpm 12.0.0 (symlinked `node_modules/.pnpm`), Node 24.20.0, macOS (Darwin 27.2.0)

## Versions tested

One run of `./repro.sh` per version. Counts change from run to run, likely because parallel scanner tasks race to open the same file.

| Biome | Total opens | Unique files | Opens of `router-core/.../route.d.ts` |
| ----- | ----------- | ------------ | -------------------------------------- |
| 2.6.9 | 997         | 531          | 10                                     |
| 2.2.0 | 914         | 551          | 10                                     |
| 2.1.4 | 7919        | 7919         | 1                                      |

2.1.4 opens each file once, but it scans all of `node_modules`. Scanner v2 (biomejs/biome#6989, first released in 2.2.0) follows imports in parallel instead. Duplicate opens start in that release, so this is not a regression within 2.2.x–2.6.x.
